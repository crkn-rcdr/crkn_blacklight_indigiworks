require 'time'
require 'json'
$:.unshift './config'
class MarcIndexer < Blacklight::Marc::Indexer
  # this mixin defines lambda factory method get_format for legacy marc formats
  include Blacklight::Marc::Indexer::Formats

  def initialize
    super

    settings do
      # type may be 'binary', 'xml', or 'json'
      provide "marc_source.type", "binary"
      # set this to be non-negative if threshold should be enforced
      provide 'solr_writer.max_skipped', -1
    end
    # https://github.com/ruby-marc/ruby-marc
    # https://github.com/traject/traject/blob/5d720e2ba0a277cf7af455763f520cd6a2d956c7/README.md?plain=1#L279
    to_field "id", extract_marc("001"), trim, first_only
    # TODO: could use the serials 990 instead 
    # 901 = "Is issue"  => Yes; otherwise (missing/different) => No
    to_field "is_issue" do |record, accumulator|
      v = record["901"]&.value&.strip
      accumulator.replace [ (v&.casecmp("Is issue")&.zero?) ? "Yes" : "No" ]
    end

    # 901 = "Is serial" => Yes; otherwise (missing/different) => No
    to_field "is_serial" do |record, accumulator|
      v = record["901"]&.value&.strip
      accumulator.replace [ (v&.casecmp("Is series")&.zero?) ? "Yes" : "No" ]
    end

    # serial_key from 902$b (first only)
    to_field "serial_key", extract_marc('902b'), first_only

    to_field "serial_title",  extract_marc('245a'), first_only do |rec, acc|
      if acc[0] && acc[0].count(":") >= 1
        parts = acc[0].split(':', 2)
        acc.replace [parts[0]]
      else
        acc.replace []
      end
    end 

    to_field 'marc_ss', get_xml
    to_field "all_text_timv", extract_all_marc_values do |r, acc|
      acc.replace [acc.join(' ')] # turn it into a single string
    end

    to_field "language_ssim", marc_languages("008[35-37]:041a:041d:")
    to_field "format", get_format

    #Look into this
    #to_field "isbn_tsim", extract_marc('020a', separator: nil) do |rec, acc|
    #     orig = acc.dup
    #     # acc.map!{|x| StdNum::ISBN.allNormalizedValues(x)} # Can't handle 'x' assigned after by them~
    #     acc << orig
    #     acc.flatten!
    #     acc.uniq!
    #end

    to_field 'material_type_ssm', extract_marc('300a'), trim_punctuation

    # Title fields
    # get rid of / in title
    # 245 So, just keeping the $a and $b could work.

    # full title
    to_field 'full_title_tsim', extract_marc('245ab')
    to_field 'full_title_ssm', extract_marc('245ab', alternate_script: false), trim_punctuation
    to_field 'full_title_vern_ssm', extract_marc('245ab', alternate_script: :only), trim_punctuation

    # primary title 
    to_field 'title_tsim', extract_marc('245a')
    to_field 'title_ssm', extract_marc('245a', alternate_script: false), trim_punctuation
    to_field 'title_vern_ssm', extract_marc('245a', alternate_script: :only), trim_punctuation

    # subtitle
    to_field 'subtitle_tsim', extract_marc('245b')
    to_field 'subtitle_ssm', extract_marc('245b', alternate_script: false), trim_punctuation
    to_field 'subtitle_vern_ssm', extract_marc('245b', alternate_script: :only), trim_punctuation

    # Other Titles
    # Alternative Title - 246 field - right into the title or right below 
    # Uniform Title - Other title is in 830 field
    # 730, 740, 240, 242, 243, 247
    to_field 'title_addl_tsim',
      extract_marc(%W{
        246abcdefgnp
        240abcdefgklmnopqrs
        242abnp
        243abcdefgklmnopqrs
        247abcdefgnp
        730abcdefgklmnopqrst
        740anp
        830adfghklmnoprstvwxy
      }.join(':'))
    to_field 'title_si', marc_sortable_title

    # Author fields
    # Make author Creator -> 100, 110, 111, 130
    # Creator -> 700, 710, 711, 720
    to_field 'author_tsim', extract_marc("100abcegqu:110abcdegnu:111acdegjnqu:130#{ATOZ}:700abcegqu:710abcdegnu:711acdegjnqu:720#{ATOZ}")
    to_field 'author_ssm', extract_marc("100abcdq:110#{ATOZ}:111#{ATOZ}:130#{ATOZ}:700abcegqu:710abcdegnu:711acdegjnqu:720#{ATOZ}", alternate_script: false)
    to_field 'author_vern_ssm', extract_marc("100abcdq:110#{ATOZ}:111#{ATOZ}:130#{ATOZ}:700abcegqu:710abcdegnu:711acdegjnqu:720#{ATOZ}", alternate_script: :only)

    # JSTOR isn't an author. Try to not use it as one
    to_field 'author_si', marc_sortable_author

    # Subject fields
    to_field 'subject_tsim', extract_marc(%W(
      600#{ATOZ}
      610#{ATOZ}
      611#{ATOZ}
      630#{ATOZ}
      647#{ATOZ}
      648#{ATOZ}
      650#{ATOZ}
      651#{ATOZ}
      653#{ATOZ}
      654#{ATOZ}
      655#{ATOZ}
      656#{ATOZ}
      657#{ATOZ}
      658#{ATOZ}
      662#{ATOZ}
      688#{ATOZ}
    ).join(':'))

    to_field 'subject_geo_ssim', extract_marc('651a:650z'), trim_punctuation

    to_field 'coordinates_srpt' do |record, accumulator|
      spatial = self.class.extract_spatial_geometries(record)
      values = []

      spatial[:boxes].each do |box|
        envelope = self.class.build_envelope_string(box)
        values << envelope if envelope
        center = self.class.box_center(box)
        values << self.class.format_point(center) if center
      end

      spatial[:points].each do |point|
        values << self.class.format_point(point)
      end

      values.compact!
      values.uniq!
      accumulator.concat(values)
    end

    to_field 'geojson_ssim' do |record, accumulator, context|
      spatial = self.class.extract_spatial_geometries(record)
      placenames = Array(context&.output_hash&.[]('subject_geo_ssim')).map { |value| value.to_s.strip }
      placenames.reject!(&:empty?)

      features = self.class.build_geojson_features(spatial, placenames)
      accumulator.concat(features) unless features.empty?
    end

    to_field 'subject_ssim', extract_marc(%W(
      600#{ATOZ}
      610#{ATOZ}
      611#{ATOZ}
      630#{ATOZ}
      647#{ATOZ}
      648#{ATOZ}
      650#{ATOZ}
      651#{ATOZ}
      653#{ATOZ}
      654#{ATOZ}
      655#{ATOZ}
      656#{ATOZ}
      657#{ATOZ}
      658#{ATOZ}
      662#{ATOZ}
      688#{ATOZ}
    ).join(':')), trim_punctuation

    # Publication fields
    # Remove the accents from the string
    #remove_accent = lambda {|rec, acc| acc.map!{|x| 
    #  x = I18n.transliterate(x)
    #  x = x.tr('?', '')
    #  x = x.tr('[', '')
    #  x = x.tr(']', '')
    #  x = x.tr('.', '')
    #  x.tr(',', '')
    #} }

    # Published statement
    to_field 'published_ssm', extract_marc('260abcefg:264abc', alternate_script: false), trim_punctuation #remove_accent
    to_field 'published_vern_ssm', extract_marc('260abcefg:264abc', alternate_script: :only), trim_punctuation #remove_accent

    # Published Dated
    to_field 'pub_date_si', marc_publication_date
    to_field 'pub_date_ssim', marc_publication_date

    # Additional CRKN Information
    to_field 'collection_tsim', extract_marc('999a')

    to_field 'is_creator' do |record, accumulator|
      values = record.fields('999').flat_map do |field|
        field.subfields.select { |sf| sf.code == 'a' }.map { |sf| sf.value.to_s.strip }
      end
      values.reject!(&:empty?)

      is_creator = values.any? { |value| value.casecmp('Creator').zero? }
      accumulator.replace [is_creator ? 'Yes' : 'No']
    end

    to_field 'depositor_tsim', extract_marc('590a')

    # Document Source
    to_field 'doc_source_tsim', extract_marc('533abcdu')

    # Rights Statement
    to_field 'rights_stat_tsim', extract_marc('540abcdfgqu')
    
    # Access Note
    to_field 'access_note_tsim', extract_marc('506abcdefgqu')

    # Original Version Note 534 - physical item desc
    to_field 'original_version_note_tsim', extract_marc('534abcefklmnoptxz')

    # Notes
    to_field 'notes_tsim', extract_marc(%W(
      500#{ATOZ}
      515#{ATOZ}
      546#{ATOZ}
    ).join(':'))

    # Source of Description
    to_field 'source_of_description_tsim', extract_marc(%W(
      588#{ATOZ}
    ))

    # Series
    # CIHM don't need?? Need to ask Jason
    # Will need for issues
    to_field 'title_series_tsim', extract_marc("440anpv:490av")

    to_field 'permalink_fulltext_ssm', extract_marc("856g")

    to_field 'date_added' do |record, accumulator| 
      raw = record['998']&.value
      if raw
        # Parse MARC timestamp (e.g., "20240716103000.0005") and format only the date
        date = Time.strptime(raw[0..7], "%Y%m%d").utc.strftime("%Y-%m-%d")
        accumulator << date
      end
    end
    to_field 'date_edited' do |record, accumulator|
      raw = record['005']&.value
      if raw
        # Parse MARC timestamp (e.g., "20240716103000.0005") into ISO8601
        iso = Time.strptime(raw[0..13], "%Y%m%d%H%M%S").utc.iso8601
        accumulator << iso
      end
    end
    # URL Fields
    notfulltext = /abstract|description|sample text|table of contents|/i
    to_field('url_fulltext_ssm') do |rec, acc|
      rec.fields('856').each do |f|
        case f.indicator2
        when '0'
          f.find_all{|sf| sf.code == 'u'}.each do |url|
            acc << url.value
          end
        when '2'
          # do nothing
        else
          z3 = [f['z'], f['3']].join(' ')
          unless notfulltext.match(z3)
            acc << f['u'] unless f['u'].nil?
          end
        end
      end
    end

    # Very similar to url_fulltext_display. Should DRY up.
    to_field 'url_suppl_ssm' do |rec, acc|
      rec.fields('856').each do |f|
        case f.indicator2
        when '2'
          f.find_all{|sf| sf.code == 'u'}.each do |url|
            acc << url.value
          end
        when '0'
          # do nothing
        else
          z3 = [f['z'], f['3']].join(' ')
          if notfulltext.match(z3)
            acc << f['u'] unless f['u'].nil?
          end
        end
      end
    end

    # Call Number fields
    to_field 'lc_callnum_ssm', extract_marc('050ab'), first_only

    first_letter = lambda {|rec, acc| acc.map!{|x| x[0]} }
    to_field 'lc_1letter_ssim', extract_marc('050ab'), first_only, first_letter, translation_map('callnumber_map')

    alpha_pat = /\A([A-Z]{1,3})\d.*\Z/
    alpha_only = lambda do |rec, acc|
      acc.map! do |x|
        (m = alpha_pat.match(x)) ? m[1] : nil
      end
      acc.compact! # eliminate nils
    end
    to_field 'lc_alpha_ssim', extract_marc('050a'), alpha_only, first_only 

    to_field 'lc_b4cutter_ssim', extract_marc('050a'), first_only

  end

  private

  def self.extract_spatial_geometries(record)
    boxes = []
    points = []
    locations = []

    record.fields('034').each do |field|
      location_box = parse_bounding_box(field)
      location_points = parse_point_values(field) || []

      boxes << location_box if location_box
      points.concat(location_points)

      next unless location_box || location_points.any?

      location_points = location_points.uniq { |point| [point[:lon], point[:lat]] }

      locations << { box: location_box, points: location_points }
    end

    boxes.uniq! { |box| [box[:west], box[:east], box[:north], box[:south]] }
    points.uniq! { |point| [point[:lon], point[:lat]] }

    { boxes: boxes, points: points, locations: locations }
  end

  def self.parse_bounding_box(field)
    west = normalize_coordinate(field['d'], :lon)
    east = normalize_coordinate(field['e'], :lon)
    north = normalize_coordinate(field['f'], :lat)
    south = normalize_coordinate(field['g'], :lat)

    return unless [west, east, north, south].all?
    return if west == east || north == south

    {
      west: [west, east].min,
      east: [west, east].max,
      north: [north, south].max,
      south: [north, south].min
    }
  end

  def self.parse_point_values(field)
    field.subfields.select { |sf| sf.code == 'p' }.filter_map do |subfield|
      parse_point(subfield.value)
    end
  end

  def self.parse_point(value)
    tokens = value.to_s.split(/[;,\s]+/).reject(&:empty?)
    parsed = tokens.filter_map { |token| parse_coordinate_token(token) }

    lat_entry = parsed.find { |entry| entry[:axis] == :lat }
    lon_entry = parsed.find { |entry| entry[:axis] == :lon }

    parsed.select { |entry| entry[:axis].nil? }.each do |entry|
      next unless entry[:value]
      if lat_entry.nil? && entry[:value].abs <= 90
        lat_entry = entry
      elsif lon_entry.nil? && entry[:value].abs > 90
        lon_entry = entry
      elsif lon_entry.nil?
        lon_entry = entry
      elsif lat_entry.nil?
        lat_entry = entry
      end
    end

    return unless lat_entry && lon_entry

    lat = lat_entry[:value]
    lon = lon_entry[:value]

    return if lat.nil? || lon.nil?
    return if lat.abs > 90 || lon.abs > 180

    { lat: lat, lon: lon }
  end

  def self.parse_coordinate_token(token)
    axis = if token =~ /[NnSs]/
             :lat
           elsif token =~ /[EeWw]/
             :lon
           end

    value = normalize_coordinate(token, axis)
    return unless value

    { value: value, axis: axis }
  end

  def self.normalize_coordinate(raw, axis = nil)
    return if raw.nil?

    text = raw.to_s.strip
    return if text.empty?

    dir = nil
    if text =~ /^([NnSsEeWw])\s*(.+)$/
      dir = Regexp.last_match(1).upcase
      text = Regexp.last_match(2)
    elsif text =~ /^(.+?)([NnSsEeWw])$/
      dir = Regexp.last_match(2).upcase
      text = Regexp.last_match(1)
    end

    sign = 1
    if dir
      sign = -1 if dir == 'S' || dir == 'W'
      axis ||= (dir == 'N' || dir == 'S') ? :lat : :lon
    end

    text = text.tr('°º', ' ')
    text = text.gsub(/[^0-9\.\-\+\s]/, ' ')
    text = text.strip

    if text.start_with?('+', '-')
      sign = -1 if text[0] == '-'
      text = text[1..]
    end

    parts = text.split(/\s+/).reject(&:empty?)

    number = nil
    if parts.length > 1
      degrees = parts[0].to_f
      minutes = parts[1] ? parts[1].to_f : 0.0
      seconds = parts[2] ? parts[2].to_f : 0.0
      number = degrees + (minutes / 60.0) + (seconds / 3600.0)
    else
      digits = parts.first
      return unless digits

      if digits.include?('.')
        number = digits.to_f
      else
        digits = digits.sub(/^0+/, '') if digits.length > 1
        deg_len =
          if axis == :lat
            [2, digits.length].min
          elsif axis == :lon
            [3, digits.length].min
          else
            digits.length >= 5 ? 3 : 2
          end

        if digits.length > deg_len + 2
          degrees = digits[0, deg_len].to_i
          minutes = digits[deg_len, 2].to_i
          remainder = digits[(deg_len + 2)..]
          seconds = remainder ? remainder.to_i : 0
          number = degrees + (minutes / 60.0) + (seconds / 3600.0)
        elsif digits.length > deg_len
          degrees = digits[0, deg_len].to_i
          minutes = digits[deg_len..].to_i
          number = degrees + (minutes / 60.0)
        else
          number = digits.to_f
        end
      end
    end

    return unless number

    number *= sign
    if axis == :lat
      return if number.abs > 90
    elsif axis == :lon
      return if number.abs > 180
    end

    number
  end

  def self.build_envelope_string(box)
    return unless box

    "ENVELOPE(#{box[:west]}, #{box[:east]}, #{box[:north]}, #{box[:south]})"
  end

  def self.box_center(box)
    return unless box

    lon = (box[:west] + box[:east]) / 2.0
    lat = (box[:north] + box[:south]) / 2.0

    return if lat.abs > 90 || lon.abs > 180

    { lon: lon, lat: lat }
  end

  def self.format_point(point)
    return unless point
    return unless point[:lon] && point[:lat]
    return if point[:lat].abs > 90 || point[:lon].abs > 180

    format('%.6f %.6f', point[:lon], point[:lat])
  end

  def self.build_geojson_features(spatial, placenames)
    names = placenames.map { |value| value.to_s.strip }.reject(&:empty?)

    features = []

    locations = Array(spatial[:locations]).reject do |location|
      location.nil? || (location[:box].nil? && Array(location[:points]).empty?)
    end

    if locations.any?
      name_index = 0
      last_name_index = names.length - 1

      locations.each do |location|
        box = location[:box]
        location_points = Array(location[:points])

        placename =
          if names.empty?
            nil
          else
            idx = [name_index, last_name_index].min
            name_index += 1 if name_index < last_name_index
            names[idx]
          end

        if (polygon_json = build_geojson_polygon(box, placename))
          features << polygon_json
        end

        location_points.each do |point|
          next unless (point_json = build_geojson_point(point, placename))
          features << point_json
        end
      end
    else
      placename = names.first

      spatial[:boxes].each do |box|
        next unless (polygon_json = build_geojson_polygon(box, placename))
        features << polygon_json
      end

      spatial[:points].each do |point|
        next unless (point_json = build_geojson_point(point, placename))
        features << point_json
      end
    end

    features.uniq
  end

  def self.build_geojson_polygon(box, placename)
    return unless box

    polygon = {
      type: 'Feature',
      geometry: {
        type: 'Polygon',
        coordinates: [[
          [box[:west], box[:south]],
          [box[:east], box[:south]],
          [box[:east], box[:north]],
          [box[:west], box[:north]],
          [box[:west], box[:south]]
        ]]
      },
      bbox: [box[:west], box[:south], box[:east], box[:north]]
    }
    polygon[:properties] = { placename: placename } if placename
    JSON.generate(polygon)
  end

  def self.build_geojson_point(point, placename)
    return unless point && point[:lon] && point[:lat]

    feature = {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [point[:lon], point[:lat]]
      }
    }
    feature[:properties] = { placename: placename } if placename
    JSON.generate(feature)
  end
end
