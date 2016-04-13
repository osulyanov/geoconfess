class Api::V1::SpotsController < Api::V1::V1Controller
  before_action :doorkeeper_authorize!
  before_action :set_spots, only: [:index]
  before_action :set_spot, only: [:show, :update, :destroy]
  load_and_authorize_resource

  resource_description do
    short 'Spots'
  end

  def_param_group :spot do
    param :spot, Hash, desc: 'Spot info' do
      param :name, String, desc: 'Name', required: true
      param :church_id, Integer, desc: 'Church ID, for static spots only'
      param :activity_type, %w(static dynamic), desc: 'Type of spot'
      param :latitude, Float, desc: 'Latitude, for dynamic only'
      param :longitude, Float, desc: 'Longitude, for dynamic only'
    end
  end

  api :GET, '/v1/me/spots', 'My Spots (for priest only)'
  description <<-EOS
    ## Description
    List of all spots of current user.
  EOS
  example <<-EOS
    [
      {
        "id": 6,
        "name": "Test Spot1",
        "activity_type": "static",
        "church_id": 1,
        "latitude": 55.3232,
        "longitude": 80.234234,
        "recurrences": [
          {
            "id": 13,
            "start_at": "08:00",
            "stop_at": "08:30",
            "week_days": [
              "Monday",
              "Wednesday",
              "Friday"
            ]
          },
          {
            "id": 14,
            "date": "2016-08-01",
            "start_at": "09:20",
            "stop_at": "09:30"
          }
        ]
      },
      {
        "id": 7,
        "name": "Test Spot 2",
        "activity_type": "dynamic",
        "latitude": 14,
        "longitude": 15
      }
    ]
  EOS
  # Stub function for documentation only
  def me_spots_stub
  end


  api :GET, '/v1/spots', 'Spots list'
  description <<-EOS
    ## Description
    List of all spots.
  EOS
  param :priest_id, Integer, desc: 'Filter by Priest'
  param :now, :bool, desc: 'Show only active right now spots'
  param :type, %w(static dynamic), desc: 'Show only spots of given type'
  param :lat, Float, desc: 'Current latitude. Required to filter by distance'
  param :lng, Float, desc: 'Current longitude. Required to filter by distance'
  param :distance, Integer, desc: 'Distance in km. Required to filter by distance'
  example <<-EOS
    [
      {
        "id": 6,
        "name": "Test Spot1",
        "activity_type": "static",
        "church": {
          "id": 1,
          "name": "Test Church",
          "latitude": 55.3232123,
          "longitude": 80.234234,
          "street": "Some street",
          "postcode": "453534531",
          "city": "Paris",
          "state": "PA",
          "country": "FR"
        },
        "latitude": 55.3232,
        "longitude": 80.234234,
        "priest": {
          "id": 24,
          "name": "Test Priest",
          "surname": "Surnemaehere"
        },
        "recurrences": [
          {
            "id": 13,
            "start_at": "08:00",
            "stop_at": "08:30",
            "week_days": [
              "Monday",
              "Wednesday",
              "Friday"
            ]
          },
          {
            "id": 14,
            "date": "2016-08-01",
            "start_at": "09:20",
            "stop_at": "09:30"
          }
        ]
      },
      {
        "id": 7,
        "name": "Test Spot 2",
        "activity_type": "dynamic",
        "latitude": 14,
        "longitude": 15,
        "priest": {
          "id": 24,
          "name": "Test Priest",
          "surname": "Surnemaehere"
        }
      }
    ]
  EOS

  def index
  end


  api! 'Show spot'
  description <<-EOS
    ## Description
    Show spot with certain ID
  EOS
  example <<-EOS
    {
      "id": 6,
      "name": "Test Spot1",
      "church": {
        "id": 1,
        "name": "Test Church",
        "latitude": 55.3232123,
        "longitude": 80.234234,
        "street": "Some street",
        "postcode": "453534531",
        "city": "Paris",
        "state": "PA",
        "country": "FR"
      },
      "activity_type": "static",
      "latitude": 55.3232,
      "longitude": 80.234234,
      "priest": {
        "id": 24,
        "name": "Test Priest",
        "surname": "Surnemaehere"
      },
      "recurrences": [
        {
          "id": 13,
          "start_at": "08:00",
          "stop_at": "08:30",
          "week_days": [
            "Monday",
            "Wednesday",
            "Friday"
          ]
        },
        {
          "id": 14,
          "date": "2016-08-01",
          "start_at": "09:20",
          "stop_at": "09:30"
        }
      ]
    }
  EOS

  def show
  end


  api! 'Create spot'
  description <<-EOS
    ## Description
    Creates spot. For admin and priest only.
    Returns code 201 with spot data if spot successfully created.
  EOS
  param_group :spot
  example <<-EOS
    {
      "id": 6,
      "name": "Test Spot1",
      "church": {
        "id": 1,
        "name": "Test Church",
        "latitude": 55.3232123,
        "longitude": 80.234234,
        "street": "Some street",
        "postcode": "453534531",
        "city": "Paris",
        "state": "PA",
        "country": "FR"
      },
      "activity_type": "static",
      "latitude": 55.3232,
      "longitude": 80.234234,
      "priest": {
        "id": 24,
        "name": "Test Priest",
        "surname": "Surnemaehere"
      },
      "recurrences": []
    }
  EOS

  def create
    @spot = current_user.spots.new(spot_params)
    if @spot.save
      render :show, status: :created
    else
      render status: :unprocessable_entity, json: { errors: @spot.errors }
    end
  end


  api! 'Update spot'
  description <<-EOS
    ## Description
    Updates spot data. For priest only.
    Returns code 200 and {result: "success"} if spot successfully updated.
  EOS
  param_group :spot

  def update
    if @spot.update_attributes(spot_params)
      render status: :ok, json: { result: 'success' }
    else
      render status: :unprocessable_entity, json: { errors: @spot.errors }
    end
  end


  api! 'Destroy spot'
  description <<-EOS
    ## Description
    Destroys spot. For priest only.
    Returns code 200 with no content if spot successfully destroyed.
  EOS

  def destroy
    if @spot.destroy
      head status: :ok
    else
      render status: :unprocessable_entity, json: { errors: @spot.errors }
    end
  end

  private

  def spot_params
    params.require(:spot).permit(:name, :church_id, :activity_type, :latitude,
                                 :longitude)
  end

  def set_spot
    @spot = Spot.find(params[:id])
  end

  def set_spots
    if params[:me] == true
      @spots = current_user.spots.includes(:recurrences)
    else
      @spots = Spot.active
      @spots = @spots.of_type(params[:type]) if params[:type].present?
      @spots = @spots.of_priest(params[:priest_id]) if params[:priest_id].to_i > 0
      if params[:lat].present? && params[:lng].present? && params[:distance].present?
        @spots = @spots.nearest(params[:lat], params[:lng], params[:distance])
      end
      @spots = @spots.now if params[:now]
    end
  end
end
