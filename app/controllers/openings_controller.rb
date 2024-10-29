class OpeningsController < ApplicationController
  def paginated_openings
    page = params[:page] || 1
    per_page = params[:per_page] || 50

    # Start with filtering based on location and title (case-insensitive)
    openings = Opening.order(updated_at: :desc)
    openings = openings.where('location ILIKE ?', "%#{params[:location]}%") if params[:location].present?
    openings = openings.where('title ILIKE ?', "%#{params[:title]}%") if params[:title].present?

    # Apply pagination after filtering
    paginated_openings = openings.page(page).per(per_page)

    render json: paginated_openings
  end

  def authorized
  end
end
