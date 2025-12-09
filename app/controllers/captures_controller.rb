class CapturesController < ApplicationController
  skip_after_action :verify_authorized, only: %i[new create]
  skip_before_action :verify_authenticity_token, only: :create

  def new
  end

  def create
    uploaded_file = params[:image]
    render json: { error: "No image provided" }, status: :unprocessable_entity and return unless uploaded_file

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
    rescue StandardError => e
      Rails.logger.error "Blob creation error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: "Upload failed: #{e.message}" }, status: :unprocessable_entity and return
    end

    session[:captured_blob_id] = blob.signed_id
    session[:captured_latitude] = params[:latitude]
    session[:captured_longitude] = params[:longitude]

    # Always redirect to comments/new with from_camera flag
    redirect_to_url = new_comment_path(from_camera: true)

    respond_to do |format|
      format.json { render json: { redirect_to: redirect_to_url } }
      format.html { redirect_to redirect_to_url }
    end
  end
end
