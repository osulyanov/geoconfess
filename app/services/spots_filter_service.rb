class SpotsFilterService
  def initialize(params, current_user)
    @params = params
    @current_user = current_user
    @spots = Spot.active.includes(:recurrences)
    filter
  end

  def results
    @spots
  end

  def available_filters
    %w(me type priest_id distance now)
  end

  def filter
    available_filters.each { |f| @spots = send("filter_by_#{f}") }
  end

  def filter_by_me
    return @spots unless @params[:me] == true
    @spots.of_priest(@current_user.id)
  end

  def filter_by_type
    return @spots unless @params[:type].present?
    @spots.of_type(@params[:type])
  end

  def filter_by_priest_id
    return @spots unless @params[:priest_id].to_i > 0
    @spots.of_priest(@params[:priest_id])
  end

  def filter_by_distance
    return @spots unless @params[:lat].present? && @params[:lng].present? &&
                         @params[:distance].present?
    @spots.nearest(@params[:lat], @params[:lng], @params[:distance])
  end

  def filter_by_now
    return @spots unless @params[:now]
    @spots.now
  end
end
