class VideosController < ApplicationController
  require 'google/api_client'
  require 'json'
  before_action :set_video, only: [:show, :edit, :update, :destroy]
  before_action :populate_videos, only: [:index]

  # GET /videos
  # GET /videos.json
  def index
    @videos = Video.all
  end

  # GET /videos/1
  # GET /videos/1.json
  def show
  end

  # GET /videos/new
  def new
    @video = Video.new
  end

  # GET /videos/1/edit
  def edit
  end

  # POST /videos
  # POST /videos.json
  def create
    @video = Video.new(video_params)

    respond_to do |format|
      if @video.save
        format.html { redirect_to @video, notice: 'Video was successfully created.' }
        format.json { render action: 'show', status: :created, location: @video }
      else
        format.html { render action: 'new' }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /videos/1
  # PATCH/PUT /videos/1.json
  def update
    respond_to do |format|
      if @video.update(video_params)
        format.html { redirect_to @video, notice: 'Video was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /videos/1
  # DELETE /videos/1.json
  def destroy
    @video.destroy
    respond_to do |format|
      format.html { redirect_to videos_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_video
      @video = Video.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def video_params
      params[:video]
    end

    def populate_videos
      client = Google::APIClient.new :application_name => 'youtube accessor'
      youtube = client.discovered_api('youtube', 'v3')
      client.authorization = nil
        

      result = client.execute :key => ENV["YOUTUBE_API_KEY"], :api_method => youtube.playlist_items.list, :parameters => {:playlistId => "PLJWtlcIkujt_Rv6JZdJt8XL2GE24k0axd", :part => 'snippet', :maxResults => 50}
      result = JSON.parse(result.data.to_json)
      result_list = result["items"]


      # [titles_in_db]
      # if title from [titles_in_db] is not in [titles_from_yt] then add it to [titles_to_remove]
      # [titles from yt]
      titles_in_db = []
      titles_from_yt = []
      titles_to_remove = []


      
      Video.all.each do |vid|
        titles_in_db << vid.title
      end


      result_list.each do |item|
        title = item["snippet"]["title"]
        titles_from_yt << title
        youtube_id = item["snippet"]["resourceId"]["videoId"]
        thumbnail_link = item["snippet"]["thumbnails"]["high"]["url"]
        if thumbnail_link == nil
          thumbnail_link = item["snippet"]["thumbnails"]["default"]["url"]
        end

        #binding.pry

        # create video unless it is already in database
        Video.create(title:title, youtube_id:youtube_id, thumbnail_link:thumbnail_link) unless Video.where(title:title).length > 0
      end


      titles_to_remove = titles_in_db - titles_from_yt
      titles_to_remove.each do |title|
        vid = Video.where(title:title)
        vid.destroy_all
      end
    end
end
