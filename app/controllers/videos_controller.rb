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
        

      result = client.execute :key => ENV["YOUTUBE_API_KEY"], :api_method => youtube.playlist_items.list, :parameters => {:playlistId => "PLECC18E60EBB421E6", :part => 'snippet'}
      result = JSON.parse(result.data.to_json)
      result_list = result["items"]
      videos = {}
      result_list.each do |item|
        title = item["snippet"]["title"]
        youtube_id = item["snippet"]["resourceId"]["videoId"]
        videos[title] = youtube_id
        Video.create(title:title, youtube_id:youtube_id) unless Video.where(title:title).length > 0
      end
    end
end
