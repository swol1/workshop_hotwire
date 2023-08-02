module Artists
  class TracksController < ApplicationController
    TRACKS_PER_PAGE = 20
  
    def index
      if turbo_frame_request?
        render partial: "track_list", locals: pagination_data.merge(artist: artist)
      else
        render :index, locals: pagination_data.merge(artist: artist)
      end
    end
  
    private
  
    def artist
      Artist.find(params[:artist_id])
    end
  
    def popular_tracks
      artist.tracks.popularity_ordered
    end
  
    def pagination_data
      page = params[:page].presence&.to_i || 1
      total_pages = [1, (popular_tracks.count / TRACKS_PER_PAGE.to_f).ceil].max
      current_page = [page, total_pages].min
      offset = (current_page - 1) * TRACKS_PER_PAGE
      {
        tracks: popular_tracks.offset(offset).limit(TRACKS_PER_PAGE),
        page: current_page,
        total_pages: total_pages,
        offset: offset
      }
    end
  end  
end
