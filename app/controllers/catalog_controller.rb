# frozen_string_literal: true
require 'pp'
# Blacklight controller that handles searches and document requests
class CatalogController < ApplicationController

  include Blacklight::Catalog
  include BlacklightRangeLimit::ControllerOverride

  include Blacklight::Marc::Catalog

  # Blacklight's track action is a redirect used for click tracking and may
  # be invoked without an authenticity token. Skip CSRF verification for it.
  skip_before_action :verify_authenticity_token, only: [:track]

  MAP_POPUP_OVERRIDES = {
    'oocihm.creator_00001' => {
      label: "George Copway (Ojibway), 1818-1869.",
      locations_only: true,
      locations: {
        /Near Rice Lake/i => "Near Rice Lake (birthplace).",
        /La Pointe/i => "La Pointe, Wisconsin (translation work completed).",
        /New York City/i => "New York City, NY (published memoir in 1847 - first book published by a First Nations author in what is now Canada)."
      }
    },
    'oocihm.creator_00003' => {
      label: "Eleazer Williams (Mohawk), 1787-1858.",
      locations_only: true,
      locations: {
        /Kahnawake/i => "Chief of Caughnawaga Reserve (now Kahnawake)."
      }
    },
    'oocihm.creator_00004' => {
      label: "Peter Jones (Ojibway), 1802-1856."
    },
    'oocihm.creator_00006' => {
      label: "Peter Warren Dease (Irish and possibly Caughnawaga Mohawk), 1788-1863.",
      locations_only: true,
      locations: {
        /Fort Mackinac/i => "Fort Mackinac (birthplace). Nation: Irish and possibly Caughnawaga Mohawk.",
        /Great Slave Lake/i => "Great Slave Lake and Fort Franklin (Deline, NWT). In 1824 he worked there procuring provisions from local Dene people for John Franklin's land Arctic expeditions; in 1825 he oversaw the construction of Fort Franklin."
      }
    },
    'oocihm.creator_00007' => {
      label: "Alfred Campbell Garrioch (Metis), 1848-1934."
    },
    'oocihm.creator_00008' => {
      label: "Ely Samuel Parker (Seneca), 1828-1895.",
      locations_only: true,
      locations: {
        /Tonawanda Reservation/i => "Tonawanda Reservation, NY (birthplace)."
      }
    },
    'oocihm.creator_00009' => {
      label: "John Alexander Mackay Kennedy (Metis), 1838-1923.",
      locations_only: true,
      locations: {
        /Mistissini/i => "Mistissini (birthplace)."
      }
    },
    'oocihm.creator_00011' => {
      label: "Maris Bryant Pierce (Seneca), 1811-1874.",
      locations_only: true,
      locations: {
        /Allegany Indian Reservation/i => "Allegany Indian Reservation, NY (birthplace)."
      }
    },
    'oocihm.creator_00012' => {
      label: "Peter Edmund Jones (Ojibway), 1843-1909.",
      locations_only: true,
      locations: {
        /London, Upper Canada/i => "London, Upper Canada (birthplace).",
        /New Credit/i => "New Credit, Ontario (led relocation)."
      }
    },
    'oocihm.creator_00013' => {
      label: "Alexander Kennedy Isbister (Metis), 1822-1883.",
      locations_only: true,
      locations: {
        /Cumberland House/i => "Cumberland House (birthplace)."
      }
    },
    'oocihm.creator_00014' => {
      label: "Isaac Bearfoot (Onondaga), 1839-1911."
    },
    'oocihm.creator_00015' => {
      label: "Henry Blatchford (Chippeway), fl. 1842."
    },
    'oocihm.creator_00020' => {
      label: "William Hess (Mohawk), fl. 1839-1843."
    },
    'oocihm.creator_00021' => {
      label: "Henry Aaron Hill (Mohawk), c.1770-1834."
    },
    'oocihm.creator_00022' => {
      label: "John Hill Jr. (Mohawk), fl. 1842.",
      locations_only: true,
      locations: {
        /Hamilton/i => "Hamilton (place of publication).",
        /Six Nations of the Grand River/i => "Six Nations of the Grand River."
      }
    },
    'oocihm.creator_00025' => {
      label: "Peter Jacobs (Ojibway), 1807-1890."
    },
    'oocihm.creator_00026' => {
      label: "Sophie Mason Thomas (Metis), 1822-1861."
    },
    'oocihm.creator_00027' => {
      label: "Robert McDonald (Metis), 1829-1913.",
      locations_only: true,
      locations: {
        /Red River Settlement/i => "Red River Settlement (birthplace)."
      }
    },
    'oocihm.creator_00028' => {
      label: "Pigarouich, also known as Etienne (Algonkin), fl. 1639-1645.",
      locations_only: true,
      locations: {
        /Sillery/i => "Jesuit mission at Sillery near Quebec City (centre of work)."
      }
    },
    'oocihm.creator_00029' => {
      label: "Sahonwagy (Mohawk), fl. 1753-1787.",
      locations_only: true,
      locations: {
        /Canajoharie/i => "Canajoharie, NY (centre of work); also known by several other names including Paulus Petersen."
      }
    },
    'oocihm.creator_00031' => {
      label: "John Summerfield (Ojibway), ca. 1806-1836.",
      locations_only: true,
      locations: {
        /Credit Mission/i => "Credit Mission, Upper Canada (birthplace)."
      }
    },
    'oocihm.creator_00032' => {
      label: "Clare Thomas (Micmac/Mi'kmaw), fl. 1757.",
      locations_only: true,
      locations: {
        /Halifax/i => "Halifax, Nova Scotia (captivity). A captive of the British in Halifax who spoke the Mi'kmaw language and French but not English; she tried to communicate by asking for pen, ink, and paper and wrote in hieroglyphics in what John Knox noted in his journal to be unintelligible. https://n2t.net/ark:/69429/m0183416xq3x See page 89-93."
      }
    },
    'oocihm.creator_00033' => {
      label: "Thomas Vincent (Metis), 1835-1907.",
      locations_only: true,
      locations: {
        /Osnaburg House/i => "Osnaburg House (birthplace)."
      }
    },
    'oocihm.creator_00034' => {
      label: "William Henry Pierce (Tsimshian), 1856-1948.",
      locations_only: true,
      locations: {
        /.*/ => "Translator and missionary who released his autobiography From Potlatch to Pulpit in 1933."
      }
    },
    'oocihm.creator_00035' => {
      label: "Pelkamulox (Okanagan Nation), ca. 1809-1810.",
      locations_only: true,
      locations: {
        /.*/ => "A talented orator who travelled great distances to hunt; after he reported meeting traders with white skin, horses, and guns, a neighbouring chief accused him of lying and fatally injured him."
      }
    }
  }.freeze


  # If you'd like to handle errors returned by Solr in a certain way,
  # you can use Rails rescue_from with a method you define in this controller,
  # uncomment:
  #
  # rescue_from Blacklight::Exceptions::InvalidRequest, with: :my_handling_method

  configure_blacklight do |config|
    ## Specify the style of markup to be generated (may be 4 or 5)
    # config.bootstrap_version = 5
    #
    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response
    #
    ## The destination for the link around the logo in the header
    # config.logo_link = root_path
    #
    ## Should the raw solr document endpoint (e.g. /catalog/:id/raw) be enabled
    # config.raw_endpoint.enabled = false

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    #config.default_solr_params = {
    #  rows: 10
    #}

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    #config.default_solr_params = {
    #  qt: "/query",
    #  q: "*:*"
    #}
    #config.default_solr_params = {
    #  defType: 'edismax' 
    #}
    # solr path which will be added to solr base url before the other solr params.
    config.solr_path = 'select'
    #config.document_solr_path = 'get'
    #config.json_solr_path = 'advanced'
    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select'
    #config.document_solr_path = 'get'

    # items to show per page, each number in the array represent another option to choose from.
    config.per_page = [10,20,50,100]

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    # solr field configuration for search results/index views
    config.index.title_field = 'full_title_tsim'
    config.view.map = Blacklight::Configuration::ViewConfig.new(partial: 'map', icon: 'bi bi-geo-alt')
    # config.index.display_type_field = 'format'
    # config.index.thumbnail_field = 'thumbnail_path_ss'

    # The presenter is the view-model class for the page
    # config.index.document_presenter_class = MyApp::IndexPresenter

    # Some components can be configured
    # config.index.document_component = MyApp::SearchResultComponent
    # config.index.constraints_component = MyApp::ConstraintsComponent
    # config.index.search_bar_component = MyApp::SearchBarComponent
    # config.index.search_header_component = MyApp::SearchHeaderComponent
    # config.index.document_actions.delete(:bookmark)

    config.add_results_document_tool(:bookmark, component: Blacklight::Document::BookmarkComponent, if: :render_bookmarks_control?)

    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)

    #config.add_show_tools_partial(:bookmark, component: Blacklight::Document::BookmarkComponent, if: :render_bookmarks_control?)
    #config.add_show_tools_partial(:email, callback: :email_action, validator: :validate_email_params)
    #config.add_show_tools_partial(:sms, if: :render_sms_action?, callback: :sms_action, validator: :validate_sms_params)
    config.add_show_tools_partial(:citation)

    config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)
    config.add_nav_action(:search_history, partial: 'blacklight/nav/search_history')

    # solr field configuration for document/show views
    # config.show.title_field = 'title_tsim'
    # config.show.display_type_field = 'format'
    # config.show.thumbnail_field = 'thumbnail_path_ss'
    #
    # The presenter is a view-model class for the page
    # config.show.document_presenter_class = MyApp::ShowPresenter
    #
    # These components can be configured
    # config.show.document_component = MyApp::DocumentComponent
    # config.show.sidebar_component = MyApp::SidebarComponent
    # config.show.embed_component = MyApp::EmbedComponent
    #config.index.title_component = IndexTitleComponent 
    #config.index.document_component = IndexDocumentComponent

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)

    
    config.add_facet_field 'pub_date_si', label: ->(_config) { I18n.t('blacklight.metadata.date_range.label') }, 
    range: {
        num_segments: 10,
        segments: true,
        maxlength: 4,
        assumed_boundaries: [1300, Time.now.year + 2],
        chart_js: false,
    }
    #config.add_facet_field 'pub_date_ssim', label: 'Publication Year', single: true
    # Suggest is the search box for the facet pop-ups
    config.add_facet_field 'language_ssim_str', label: ->(_config) { I18n.t('blacklight.metadata.language.label') }, sort: 'index', limit: 8, suggest: true, index_range: true
    config.add_facet_field 'collection_tsim_str', label: ->(_config) { I18n.t('blacklight.metadata.material.label') }, sort: 'count', limit: 8, suggest: true, index_range: true # Need to figure out why old values aren't clearing
    config.add_facet_field 'depositor_tsim_str', label:->(_config) { I18n.t('blacklight.metadata.depositor.label') }, sort: 'count', limit: 8, suggest: true, index_range: true
    config.add_facet_field 'subject_ssim_str', label: ->(_config) { I18n.t('blacklight.metadata.subject.label') }, sort: 'count', limit: 8, suggest: true, index_range: true
    config.add_facet_field 'author_ssm_str', label:  ->(_config) { I18n.t('blacklight.metadata.creator.label') }, sort: 'count', limit: 8, suggest: true, index_range: true
    config.add_facet_field 'is_issue_str', label: ->(_config) { I18n.t('blacklight.metadata.issue_msg.label') }, sort: 'count', limit: 8, suggest: true, index_range: true
    config.add_facet_field 'is_serial_str', label: ->( _config) { I18n.t('blacklight.metadata.serial_msg.label') }, sort: 'count', limit: 8, suggest: true, index_range: true
    
    #config.add_facet_field 'format', label: 'Format'
    #config.add_facet_field 'subject_ssim', label: 'Topic', limit: 20, index_range: 'A'..'Z'
    #config.add_facet_field 'language_ssim', label: 'Language', limit: true
    #config.add_facet_field 'lc_1letter_ssim', label: 'Call Number'
    #config.add_facet_field 'subject_geo_ssim', label: 'Region'
    #config.add_facet_field 'subject_era_ssim', label: 'Era'

    #config.add_facet_field 'example_pivot_field', label: 'Pivot Field', pivot: ['format', 'language_ssim'], collapsing: true

    #config.add_facet_field 'example_query_facet_field', label: 'Publish Date', :query => {
    #   :years_5 => { label: 'within 5 Years', fq: "pub_date_ssim:[#{Time.zone.now.year - 5 } TO *]" },
    #   :years_10 => { label: 'within 10 Years', fq: "pub_date_ssim:[#{Time.zone.now.year - 10 } TO *]" },
    #   :years_25 => { label: 'within 25 Years', fq: "pub_date_ssim:[#{Time.zone.now.year - 25 } TO *]" }
    #}


    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'format', label: 'Format', helper_method: :format_icon
    #   Title
    config.add_index_field 'title_ssm',  label: ->(_field, _config) { I18n.t('blacklight.metadata.title.label') }, helper_method: :format_text
    #   Creator
    config.add_index_field 'author_ssm', label: ->(_field, _config) { I18n.t('blacklight.metadata.creator.label') }, helper_method: :format_facet
    #   Published
    config.add_index_field 'published_ssm', label: ->(_field, _config) { I18n.t('blacklight.metadata.published.label') }
    #   Published Date
    config.add_index_field 'pub_date_si', label: ->(_field, _config) { I18n.t('blacklight.metadata.date.label') }
    #   Identifier
    # config.add_index_field 'id', label: ->(_field, _config) { I18n.t('blacklight.metadata.id.label') }
    #   Subject
    config.add_index_field 'subject_ssim', label: ->(_field, _config) { I18n.t('blacklight.metadata.subject.label') }, helper_method: :format_facet
    #   Collection
    config.add_index_field 'collection_tsim', label: ->(_field, _config) { I18n.t('blacklight.metadata.material.label') }, helper_method: :format_facet
    #   Depositor
    config.add_index_field 'depositor_tsim', label: ->(_field, _config) { I18n.t('blacklight.metadata.depositor.label') }, helper_method: :format_facet
    #   Language
    config.add_index_field 'language_ssim', label: ->(_field, _config) { I18n.t('blacklight.metadata.language.label') }, helper_method: :format_facet
    #   Notes
    config.add_index_field 'notes_tsim', label: ->(_field, _config) { I18n.t('blacklight.metadata.notes.label') }, helper_method: :format_text
    config.add_index_field 'original_version_note_tsim', label: ->(_field, _config) { I18n.t('blacklight.metadata.original_version_note.label') }, helper_method: :format_text
    config.add_index_field 'access_note_tsim', label: ->(_field, _config) { I18n.t('blacklight.metadata.access_note.label') }, helper_method: :format_text
    #   URL
    config.add_index_field 'ark', label: ->(_field, _config) { I18n.t('blacklight.metadata.persistent_url.label') }, helper_method: :value_link
    config.add_index_field 'date_added', label: ->(_field, _config) { I18n.t('blacklight.metadata.date_added.label') }, helper_method: :format_date
    #config.add_index_field 'pub_date_si', label: 'Date'
    #config.add_index_field 'collection_tsim', label: 'Material', helper_method: :value_link
    #config.add_index_field 'doc_source_tsim', label: 'Originating Institution', helper_method: :value_link
    #config.add_index_field 'id', label: 'Item Code'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    #config.add_show_field 'title_tsim', label: 'Title'
    #config.add_show_field 'title_vern_ssim', label: 'Title'
    #config.add_show_field 'subtitle_tsim', label: 'Subtitle'
    #config.add_show_field 'subtitle_vern_ssim', label: 'Subtitle'
    #config.add_show_field 'author_tsim', label: 'Author'
    #config.add_show_field 'author_vern_ssim', label: 'Author'
    #config.add_show_field 'format', label: 'Format'
    #config.add_show_field 'url_fulltext_ssim', label: 'URL'
    #config.add_show_field 'url_suppl_ssim', label: 'More Information'
    #config.add_show_field 'language_ssim', label: 'Language'
    #config.add_show_field 'published_ssim', label: 'Published'
    #config.add_show_field 'published_vern_ssim', label: 'Published'
    #config.add_show_field 'lc_callnum_ssim', label: 'Call number'
    #config.add_show_field 'isbn_ssim', label: 'ISBN'

    #   Title
    config.add_show_field 'title_ssm',  label: ->(_field, _config) { I18n.t('blacklight.metadata.title.label') }, helper_method: :format_text
    config.add_show_field 'subtitle_tsim', label: ->(_field, _config) { I18n.t('blacklight.metadata.subtitle.label') }, helper_method: :format_text
    config.add_show_field 'title_addl_tsim', label: ->(_field, _config) { I18n.t('blacklight.metadata.other_titles.label') }, helper_method: :format_text
    #   Creator
    config.add_show_field 'author_ssm', label: ->(_field, _config) { I18n.t('blacklight.metadata.creator.label') }, helper_method: :format_facet
    #   Published
    config.add_show_field 'published_ssm', label: ->(_field, _config) { I18n.t('blacklight.metadata.published.label') }
    #   Published Date
    config.add_show_field 'pub_date_si', label: ->(_field, _config) { I18n.t('blacklight.metadata.date.label') }
    #   Identifier
    # config.add_show_field 'id', label: ->(_field, _config) { I18n.t('blacklight.metadata.id.label') }
    config.add_show_field 'subject_ssim', label: ->(_field, _config) { I18n.t('blacklight.metadata.subject.label') }, helper_method: :format_facet
    config.add_show_field 'collection_tsim', label: ->(_field, _config) { I18n.t('blacklight.metadata.material.label') }, helper_method: :format_facet
    #   Depositor
    config.add_show_field 'depositor_tsim', label: ->(_field, _config) { I18n.t('blacklight.metadata.depositor.label') }, helper_method: :format_facet
    #   Language
    config.add_show_field 'language_ssim', label: ->(_field, _config) { I18n.t('blacklight.metadata.language.label') }, helper_method: :format_facet
    #config.add_show_field 'doc_source_tsim', label: 'Originating Institution'
    config.add_show_field 'notes_tsim', label: ->(_field, _config) { I18n.t('blacklight.metadata.notes.label') }, helper_method: :format_text
    config.add_show_field 'original_version_note_tsim', label: ->(_field, _config) { I18n.t('blacklight.metadata.original_version_note.label') }, helper_method: :format_text
    config.add_show_field 'access_note_tsim', label: ->(_field, _config) { I18n.t('blacklight.metadata.access_note.label') }, helper_method: :format_text
    config.add_show_field 'source_of_description_tsim', label: ->(_field, _config) { I18n.t('blacklight.metadata.source_of_description.label') }, helper_method: :format_text
    config.add_show_field 'rights_stat_tsim', label: ->(_field, _config) { I18n.t('blacklight.metadata.right_statements.label') }, helper_method: :format_text
    config.add_show_field 'ark', label: ->(_field, _config) { I18n.t('blacklight.metadata.persistent_url.label') }, helper_method: :value_link
    config.add_show_field 'date_added', label: ->(_field, _config) { I18n.t('blacklight.metadata.date_added.label') }, helper_method: :format_date

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field 'all_fields', label: ->(_config) { I18n.t('blacklight.metadata.all_fields.label') }

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('full_title_tsim') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = {
        qf: 'full_title_tsim',
        pf: 'full_title_tsim'
      }
      field.label = ->(_config) { I18n.t('blacklight.metadata.title.label') }
    end

    config.add_search_field('author_tsim') do |field|
      field.solr_parameters = {
        qf: 'author_tsim',
        pf: 'author_tsim'
      }
      field.label = ->(_config) { I18n.t('blacklight.metadata.creator.label') }
    end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    config.add_search_field('subject_tsim') do |field|
      field.qt = 'search'
      field.solr_parameters = {
        qf: 'subject_tsim',
        pf: 'subject_tsim'
      }
      field.label = ->(_config) { I18n.t('blacklight.metadata.subject.label') }
    end

    config.add_search_field('tx_gen') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = {
        qf: 'tx_gen',
        pf: 'tx_gen'
      }
      field.label = ->(_config) { I18n.t('blacklight.metadata.fulltx.label') }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the Solr field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case). Add the sort: option to configure a
    # custom Blacklight url parameter value separate from the Solr sort fields.
    config.add_sort_field 'relevance', sort: 'score desc, pub_date_si desc', label: ->(_config) { I18n.t('blacklight.sort.relevance.label') }
    config.add_sort_field 'year-desc', sort: 'pub_date_si desc', label: ->(_config) { I18n.t('blacklight.sort.year_desc.label') }
    config.add_sort_field 'year-asc', sort: 'pub_date_si asc', label: ->(_config) { I18n.t('blacklight.sort.year_asc.label') }
    config.add_sort_field 'date-added-desc', sort: 'date_added desc', label: ->(_config) { I18n.t('blacklight.sort.date_added_desc.label') }
    config.add_sort_field 'date-added-asc', sort: 'date_added  asc', label: ->(_config) { I18n.t('blacklight.sort.date_added_asc.label') }

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggester
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'
    # if the name of the solr.SuggestComponent provided in your solrconfig.xml is not the
    # default 'mySuggester', uncomment and provide it below
    # config.autocomplete_suggester = 'mySuggester'

    config.filter_search_state_fields = true
    config.document_solr_path = 'select'
    config.fetch_by_id_solr_params = lambda do |solr_params, id|
      solr_params[:qt] = nil
      solr_params[:q] = %({!term f=#{config.document_unique_id_param}}#{RSolr.solr_escape(id)})
      solr_params[:rows] = 1
    end
    config.fetch_many_document_params = lambda do |solr_params, ids|
      solr_params[:qt] = nil
      solr_params[:q] = %({!terms f=#{config.document_unique_id_param}}#{ids.map { |value| RSolr.solr_escape(value) }.join(',')})
      solr_params[:rows] = ids.length
    end
  end

def map_geojson
  limit_param = params[:map_limit]
  limit = limit_param.present? ? limit_param.to_i : 1000
  limit = 1000 if limit <= 0
  limit = [limit, 1000].min

  base_search_params = search_state.params_for_search.except(:rows, :per_page, :page, :lang, :format)
  user_params = base_search_params.merge(rows: limit, page: 1)

  builder = search_service.search_builder.with(user_params)
  response = search_service.repository.search(builder)
  documents = response.documents

  features = documents.flat_map do |document|
    doc_hash = document.respond_to?(:to_h) ? document.to_h : document
    next [] unless doc_hash

    doc_id = if document.respond_to?(:id)
               document.id
             elsif doc_hash.respond_to?(:[])
               doc_hash['id'] || doc_hash[:id]
             end
    doc_id = doc_id.to_s if doc_id

    image_url = creator_image_url(doc_hash)
    subject_geo_values = Array(doc_hash['subject_geo_ssim'])

    Array(doc_hash['geojson_ssim']).each_with_index.filter_map do |value, index|
      feature = parse_geojson_feature(value)
      next unless feature.is_a?(Hash)

      feature['properties'] ||= {}
      props = feature['properties']
      props['id'] ||= document.id if document.respond_to?(:id)
      props['title'] ||= document.to_s
      props['url'] ||= helpers.url_for_document(document)
      props['authors'] ||= Array(doc_hash['author_ssm']).first

      placename_value = nil
      if subject_geo_values.respond_to?(:[]) && subject_geo_values.size > index
        placename_value = subject_geo_values[index]
      elsif subject_geo_values.respond_to?(:first)
        placename_value = subject_geo_values.first
      end

      metadata = map_popup_metadata(doc_id, placename_value)
      next unless metadata[:visible]

      if metadata[:label].present?
        props['author_ssm_str'] = metadata[:label]
        props['authors'] = metadata[:label]
        props['author_ssm'] = [metadata[:label]]
      end

      final_placename =
        if metadata[:placename].present?
          metadata[:placename]
        elsif placename_value.respond_to?(:present?) ? placename_value.present? : placename_value.to_s.strip.present?
          ensure_trailing_period(placename_value)
        elsif props['placename'].respond_to?(:present?) ? props['placename'].present? : props['placename'].to_s.strip.present?
          ensure_trailing_period(props['placename'])
        end
      props['placename'] = final_placename if final_placename.present?

      props['image_url'] ||= image_url if image_url
      Rails.logger.info  { "DOC_HASH:
#{doc_hash.pretty_inspect}" }
      feature
    end
  end
  render json: { type: 'FeatureCollection', features: features }
rescue StandardError => e
  Rails.logger.error("map_geojson generation failed: #{e.message}")
  render json: { error: 'Unable to load map data' }, status: :unprocessable_entity
end

  def geojson
    permitted = params.permit(:id, :lang)
    solr_document = search_service.fetch(permitted[:id])
    solr_document = solr_document.last if solr_document.is_a?(Array)
    return head :not_found unless solr_document
    doc_hash = solr_document.respond_to?(:to_h) ? solr_document.to_h : solr_document
    Rails.logger.info  { "DOC_HASH:\n#{doc_hash.pretty_inspect}" }

    doc_id = if doc_hash.respond_to?(:[])
               doc_hash['id'] || doc_hash[:id]
             end
    doc_id = doc_id.to_s if doc_id

    subject_geo_values = Array(doc_hash['subject_geo_ssim'])
    authors = Array(doc_hash['author_ssm']).filter_map { |value| value.respond_to?(:presence) ? value.presence&.to_s : value.to_s.presence }
    authors += Array(doc_hash['author_ssm_str']).filter_map { |value| value.respond_to?(:presence) ? value.presence&.to_s : value.to_s.presence }
    authors += Array(doc_hash['creator_ssm']).filter_map { |value| value.respond_to?(:presence) ? value.presence&.to_s : value.to_s.presence }
    authors.uniq! if authors.respond_to?(:uniq!)

    image_url = creator_image_url(doc_hash)

    features = []
    placenames = []

    Array(doc_hash['geojson_ssim']).each_with_index do |value, index|
      feature = parse_geojson_feature(value)
      next unless feature.is_a?(Hash)

      props = feature['properties'] ||= {}
      props['author_ssm'] ||= authors if authors.any?
      props['author_ssm_str'] ||= authors.first if authors.any?
      props['authors'] ||= authors if authors.any?
      props['image_url'] ||= image_url if image_url

      placename_value = nil
      if subject_geo_values.respond_to?(:[]) && subject_geo_values.size > index
        placename_value = subject_geo_values[index]
      elsif subject_geo_values.respond_to?(:first)
        placename_value = subject_geo_values.first
      end

      metadata = map_popup_metadata(doc_id, placename_value)
      next unless metadata[:visible]

      if metadata[:label].present?
        props['author_ssm_str'] = metadata[:label]
        props['author_ssm'] = [metadata[:label]]
        props['authors'] = metadata[:label]
      end

      final_placename =
        if metadata[:placename].present?
          metadata[:placename]
        elsif placename_value.respond_to?(:present?) ? placename_value.present? : placename_value.to_s.strip.present?
          ensure_trailing_period(placename_value)
        elsif props['placename'].respond_to?(:present?) ? props['placename'].present? : props['placename'].to_s.strip.present?
          ensure_trailing_period(props['placename'])
        end

      if final_placename.present?
        props['placename'] = final_placename
        placenames << final_placename
      end

      features << feature
    end

    placenames.uniq! if placenames.respond_to?(:uniq!)
    override_label = MAP_POPUP_OVERRIDES[doc_id]&.[](:label)
    override_label = ensure_trailing_period(override_label) if override_label.present?
    authors_payload =
      if override_label.present?
        [override_label]
      else
        authors
      end

    payload = { type: 'FeatureCollection', features: features }
    properties_payload = {}
    properties_payload[:placenames] = placenames if placenames.respond_to?(:present?) ? placenames.present? : placenames.any?
    properties_payload[:authors] = authors_payload if authors_payload.any?
    payload[:properties] = properties_payload if properties_payload.any?

    bbox = compute_feature_collection_bbox(features)
    payload[:bbox] = bbox if bbox
    render json: payload
  rescue Blacklight::Exceptions::RecordNotFound
    head :not_found
  rescue NoMethodError => e
    Rails.logger.error("geojson generation failed for #{permitted[:id]}: #{e.message}")
    head :unprocessable_entity
  end
  private

  def parse_geojson_feature(value)
    return value if value.is_a?(Hash) && value['type'] == 'Feature'
    json = value.is_a?(String) ? JSON.parse(value) : value
    return json if json.is_a?(Hash) && json['type'] == 'Feature'
  rescue JSON::ParserError
    nil
  end

  def flatten_geo_coordinates(coords, acc = [])
    return acc unless coords
    if coords.is_a?(Array)
      first = coords.first
      if first.is_a?(Numeric) || first.is_a?(String)
        lon, lat = coords[0], coords[1]
        begin
          lon_val = Float(lon)
          lat_val = Float(lat)
          acc << [lon_val, lat_val] if lon_val.finite? && lat_val.finite?
        rescue ArgumentError, TypeError
        end
      else
        coords.each { |child| flatten_geo_coordinates(child, acc) }
      end
    end
    acc
  end

  def compute_feature_collection_bbox(features)
    points = features.flat_map do |feature|
      geometry = feature['geometry']
      next [] unless geometry.is_a?(Hash)
      flatten_geo_coordinates(geometry['coordinates'])
    end
    return nil if points.empty?
    lons = points.map(&:first)
    lats = points.map(&:last)
    [lons.min, lats.min, lons.max, lats.max]
  end

  def creator_image_url(doc_hash)
    return unless doc_hash
    identifier = doc_hash['id'] || doc_hash[:id]
    return unless identifier

    identifier = identifier.to_s.strip
    return if identifier.empty?

    "/assets/iw/#{identifier}.jpeg"
  end

  def map_popup_metadata(doc_id, placename_value)
    override = MAP_POPUP_OVERRIDES[doc_id.to_s] if doc_id
    placename_text = if placename_value.respond_to?(:to_s)
                       value = placename_value.to_s.strip
                       value unless value.empty?
                     end

    metadata = { visible: true, label: nil, placename: nil }

    if override
      label = override[:label]
      metadata[:label] = ensure_trailing_period(label) if label.present?

      locations = override[:locations]
      if placename_text
        if locations.present?
          match = locations.find { |pattern, _| pattern === placename_text }
          if match
            replacement = match.last
            if replacement.nil?
              metadata[:visible] = false
            else
              metadata[:placename] = ensure_trailing_period(replacement)
            end
          elsif override[:locations_only]
            metadata[:visible] = false
          end
        elsif override[:locations_only]
          metadata[:visible] = false
        end
      elsif override[:locations_only]
        metadata[:visible] = false
      end
    end

    if metadata[:visible] && metadata[:placename].blank? && placename_text
      metadata[:placename] = ensure_trailing_period(placename_text)
    end

    metadata
  end

  def ensure_trailing_period(value)
    return if value.nil?
    text = value.to_s.strip
    return if text.empty?
    return text if text.end_with?('.', '!', '?')
    "#{text}."
  end
end



