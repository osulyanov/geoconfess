class SpotsFilterService
  def initialize(params, current_user)
    @params = params
    @current_user = current_user
    @spots = Spot.active.includes(:recurrences)
    filter
  end

  # Returns spots.
  def results
    @spots
  end

  # Returns an array of all available filters.
  def available_filters
    %w(me type priest_id distance now)
  end

  # Filter spots using each filter method.
  def filter
    available_filters.each { |f| @spots = send("filter_by_#{f}") }
  end

  # Filter by priest, returns spots of current user.
  #
  # Expects params[:me] to be +true+.
  def filter_by_me
    return @spots unless @params[:me] == true
    @spots.of_priest(@current_user.id)
  end

  # Filter by activity type.
  #
  # Expects params[:type] to be present.
  # Possible types: +static+, +dynamic+.
  def filter_by_type
    return @spots unless @params[:type].present?
    @spots.of_type(@params[:type])
  end

  # Filter spots by priest.
  #
  # Expects params[:priest_id] as integer.
  def filter_by_priest_id
    return @spots unless @params[:priest_id].to_i > 0
    @spots.of_priest(@params[:priest_id])
  end

  # Filter spots by distance.
  #
  # Expects <tt>params[:lat]</tt>, <tt>@params[:lng]</tt> and
  # <tt>params[:distance]</tt> to be present.
  def filter_by_distance
    return @spots unless @params[:lat].present? && @params[:lng].present? &&
                         @params[:distance].present?
    @spots.nearest(@params[:lat], @params[:lng], @params[:distance])
  end

  # Filer spots by active right now.
  #
  # Expects <tt>params[:now]</tt> to be +true+.
  def filter_by_now
    return @spots unless @params[:now]
    @spots.now
  end
end
