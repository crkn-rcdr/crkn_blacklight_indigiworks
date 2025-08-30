class DownloadsController < ApplicationController
    def index
        @documentId            = params[:id]
        @ark                   = params[:ark]
        key                    =  Rails.configuration.x.cap_pass
        expires                = (Time.now.to_i + 86400).to_s
        swift_uri              = "https://swift.canadiana.ca"


        doc_pdf_uri                = ""
        canvas_pdf_download_uris   = []
        canvas_img_download_uris   = []

        # Build signed URL for full searchable PDF
        if @ark.present? && key.present?
          expires_i             = Time.now.to_i + 86400  # expires in a day
          path                  = File.join("/v1/AUTH_crkn/access-files", "/#{@ark}.pdf")
          payload               = "GET\n#{expires_i}\n#{path}"
          digest                = OpenSSL::Digest.new('sha1')
          signature             = OpenSSL::HMAC.hexdigest(digest, key, payload)
          uri_suffix            = "&temp_url_expires=#{expires_i}&temp_url_sig=#{signature}"
          doc_pdf_uri           = "#{swift_uri}#{path}?filename=#{@documentId}.pdf#{uri_suffix}"
        end

        # Fetch manifest to derive per-canvas PDF download URLs
        begin
          uri = URI(Rails.configuration.x.iiif_manifest_base+"/"+@ark)
          res = Net::HTTP.get(uri)
          result = JSON.parse(res) rescue {}
          items = result['items'] || []
          canvasNumber = 0
          items.each do |canvas|
            canvasNumber += 1
            thumb = canvas.dig('thumbnail', 0, 'id')
            next unless thumb
            match = thumb.match(%r{2/(.*?)/full})
            next unless match
            extracted_string = match[1]
            canvasId              = extracted_string.gsub('%2F', '/').gsub('%2f', '/')
            expires_i             = Time.now.to_i + 86400
            path                  = File.join("/v1/AUTH_crkn/access-files", "/#{canvasId}.pdf")
            payload               = "GET\n#{expires_i}\n#{path}"
            digest                = OpenSSL::Digest.new('sha1')
            signature             = OpenSSL::HMAC.hexdigest(digest, key, payload)
            uri_suffix            = "&temp_url_expires=#{expires_i}&temp_url_sig=#{signature}"
            canvas_pdf_uri        = "#{swift_uri}#{path}?filename=#{@documentId}.#{canvasNumber}.pdf#{uri_suffix}"
            canvas_img_uri        = "https://image-tor.canadiana.ca/iiif/2/#{extracted_string}/full/max/0/default.jpg"
            canvas_pdf_download_uris << canvas_pdf_uri
            canvas_img_download_uris << canvas_img_uri
          end
        rescue => e
          Rails.logger.warn("DownloadsController manifest error: #{e.class}: #{e.message}") if defined?(Rails)
        end
        render :json => {"canvasDownloadPdfUris"  => canvas_pdf_download_uris, "docPdfUri" => doc_pdf_uri, "canvasDownloadImgUris" => canvas_img_download_uris}
    end
end
