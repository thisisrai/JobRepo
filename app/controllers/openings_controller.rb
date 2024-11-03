class OpeningsController < ApplicationController
  def paginated_openings
    page = params[:page] || 1
    per_page = params[:per_page] || 50

    # Start with filtering based on location and title (case-insensitive)
    openings = Opening.order(posted_on: :desc)
    openings = openings.where('location ILIKE ?', "%#{params[:location]}%") if params[:location].present?
    openings = openings.where('title ILIKE ?', "%#{params[:title]}%") if params[:title].present?

    # Get total count before pagination
    total_count = openings.count

    # Apply pagination after filtering
    paginated_openings = openings.page(page).per(per_page)

    # Render JSON with paginated data and total count
    render json: {
      total_count: total_count,
      data: paginated_openings
    }
  end

  def authorized
  end
end