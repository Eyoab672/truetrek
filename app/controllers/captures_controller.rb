class CapturesController < ApplicationController
  skip_after_action :verify_authorized, only: %i[new create]
  def new
  end

  def create
    authorize :capture, :create?
    uploaded_file = params[:image] # ActionDispatch::Http::UploadedFile
    unless uploaded_file
      render json: { error: "No image provided" }, status: :unprocessable_entity and return
    end

    blob = ActiveStorage::Blob.create_and_upload!(
      io: uploaded_file.tempfile,
      filename: uploaded_file.original_filename || "capture.png",
      content_type: uploaded_file.content_type || "image/png"
    )

    session[:captured_blob_id] = blob.signed_id
    session[:captured_latitude] = params[:latitude]
    session[:captured_longitude] = params[:longitude]

    redirect_to_url =
      case params[:next_action]
      when "new_place"
        new_place_path
      when "existing_place"
        places_path   # or a custom "choose place" path
      else
        root_path
      end

    respond_to do |format|
      format.json { render json: { redirect_to: redirect_to_url } }
      format.html { redirect_to redirect_to_url }
    end
  end
end
