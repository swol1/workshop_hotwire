class ArtistsController < ApplicationController
  def show
    artist = Artist.find(params[:id])
    albums = selected_albums(artist.albums, params[:album_type]).with_attached_cover.preload(:artist)
    limit, tracks, tracks_amount = fetch_popular_tracks_with_count(artist)

    if turbo_frame_request?
      if turbo_frame_request_id.match?(/discography/)
        render partial: "discography", locals: {artist:, albums:}
      elsif turbo_frame_request_id.match?(/popular_tracks/)
        render partial: "popular_tracks", locals: {artist:, tracks:, limit:, tracks_amount:}
      end
    else
      render action: :show, locals: {artist:, albums:, tracks:, limit:, tracks_amount:}
    end
  end

  private

  def fetch_popular_tracks_with_count(artist)
    limit = [params.fetch(:limit, 0).to_i, 0].max + 5
    tracks = artist.tracks.popularity_ordered
    tracks_amount = tracks.count
    tracks = tracks.limit(limit)
  
    [limit, tracks, tracks_amount]
  end

  def selected_albums(albums, album_type)
    return albums.lp if album_type.blank?

    return albums.lp unless Album.kinds.key?(album_type)

    albums.where(kind: album_type)
  end
end
