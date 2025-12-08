class CapturesController < ApplicationController
  skip_after_action :verify_authorized, only: %i[new create]
  skip_before_action :verify_authenticity_token, only: :create

  def new
  end

  def create
    uploaded_file = params[:image]
    unless uploaded_file
      render json: { error: "No image provided" }, status: :unprocessable_entity and return
    end

    begin
      # Handle both regular file uploads and blob uploads from camera
      io = uploaded_file.respond_to?(:tempfile) ? uploaded_file.tempfile : uploaded_file
      filename = uploaded_file.respond_to?(:original_filename) ? uploaded_file.original_filename : "capture.png"
      content_type = uploaded_file.respond_to?(:content_type) ? uploaded_file.content_type : "image/png"

      blob = ActiveStorage::Blob.create_and_upload!(
        io: io,
        filename: filename || "capture.png",
        content_type: content_type || "image/png"
      )
    rescue => e
      Rails.logger.error "Blob creation error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: "Upload failed: #{e.message}" }, status: :unprocessable_entity and return
    end

    session[:captured_blob_id] = blob.signed_id
    session[:captured_latitude] = params[:latitude]
    session[:captured_longitude] = params[:longitude]

    redirect_to_url =
      case params[:next_action]
      when "new_place"
        new_place_path
      when "existing_place"
        # For existing place, go to comments new page with place selection
        if params[:place_id].present?
          new_comment_path(place_id: params[:place_id], from_camera: true)
        else
          new_comment_path(from_camera: true)
        end
      else
        root_path
      end

    respond_to do |format|
      format.json { render json: { redirect_to: redirect_to_url } }
      format.html { redirect_to redirect_to_url }
    end
  end
end
