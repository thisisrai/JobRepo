class OpeningsController < ApplicationController
  def paginated_openings
    page = params[:page] || 1
    per_page = params[:per_page] || 50

    # Start with filtering based on location and title (case-insensitive)
    openings = Opening.order(posted_on: :desc)
    openings = openings.where('location ILIKE ?', "%#{params[:location]}%") if params[:location].present?
    openings = openings.where('title ILIKE ?', "%#{params[:title]}%") if params[:title].present?

    if params[:company].present?
      openings = openings.where(company: params[:company])
      total_count = openings.count
    else
      latest_openings = Opening
        .from(openings, :openings)
        .select("DISTINCT ON (company) *")
        .order("company, posted_on DESC") # Ensures DISTINCT ON works correctly

      ordered_openings = Opening
        .from(latest_openings, :openings)
        .order(posted_on: :desc) # Final ordering based on posted_on

      total_count = ordered_openings.size
      openings = ordered_openings
    end

    # Get total count before pagination

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