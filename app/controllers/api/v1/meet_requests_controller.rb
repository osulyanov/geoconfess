class Api::V1::MeetRequestsController < Api::V1::V1Controller
  before_action :doorkeeper_authorize!
  before_action :set_meet_request, only: [:show, :update, :destroy, :accept, :refuse]
  load_and_authorize_resource

  resource_description do
    short 'Requests'
  end

  api! 'All requests of current user'
  description <<-EOS
    ## Description
    All active requests where priest_id or penitent_id equal to current_user.id.
    User's location available for priest only.
  EOS
  param :party_id, Integer, desc: 'Filter by the other party of meeting'
  example <<-EOS
    [
      {
        "id": 4,
        "priest_id": 24,
        "penitent_id": 25,
        "status": "pending",
        "latitude": "24.123234",
        "longitude": "21.234234"
      }
    ]
  EOS

  def index
    @meet_requests = MeetRequest.active.for_user(current_user.id)
    @meet_requests = @meet_requests.for_user(params[:party_id]) if params[:party_id]
  end


  api! 'Show request'
  description <<-EOS
    ## Description
    Show request with certain ID.
    User's location available for priest only.
  EOS
  example <<-EOS
    {
      "id": 4,
      "priest_id": 24,
      "penitent_id": 25,
      "status": "pending",
      "latitude": "24.123234",
      "longitude": "21.234234"
    }
  EOS

  def show
  end


  api! 'Create request'
  description <<-EOS
    ## Description
    Creates request
    Returns code 201 with request data if request successfully created.
  EOS
  param :request, Hash, desc: 'User info' do
    param :priest_id, Integer, desc: 'Priest ID', required: true
    param :latitude, Integer, desc: 'Current user\'s latitude', required: true
    param :longitude, Integer, desc: 'Current user\'s longitude', required: true
    param :status, ['pending', 'accepted', 'refused'], desc: 'Status. For admin only.'
  end

  def create
    @meet_request = MeetRequest.new(request_params)
    @meet_request.penitent_id = current_user.id
    if @meet_request.save
      render :show, status: :created
    else
      render status: :unprocessable_entity, json: { errors: @meet_request.errors }
    end
  end


  api! 'Update request'
  description <<-EOS
    ## Description
    Updates request data
    Returns code 200 and {result: "success"} if request successfully updated.
  EOS
  param :request, Hash, desc: 'User info' do
    param :priest_id, Integer, desc: 'Priest ID', required: true
    param :status, ['pending', 'accepted', 'refused'], desc: 'Status. For admin only.'
  end

  def update
    if @meet_request.update_attributes(request_params)
      render status: :ok, json: { result: 'success' }
    else
      render status: :unprocessable_entity, json: { errors: @meet_request.errors }
    end
  end


  api! 'Destroy request'
  description <<-EOS
    ## Description
    Destroys request
    Returns code 200 with no content if request successfully destroyed.
  EOS

  def destroy
    if @meet_request.destroy
      head status: :ok
    else
      render status: :unprocessable_entity, json: { errors: @meet_request.errors }
    end
  end


  api! 'Accept request'
  description <<-EOS
    ## Description
    Sets status to accepted
    Returns code 200 with no content if request successfully updated.
  EOS

  def accept
    if @meet_request.accepted!
      head status: :ok
    else
      render status: :unprocessable_entity, json: { errors: @meet_request.errors }
    end
  end


  api! 'Refuse request'
  description <<-EOS
    ## Description
    Sets status to refused
    Returns code 200 with no content if request successfully updated.
  EOS

  def refuse
    if @meet_request.refused!
      head status: :ok
    else
      render status: :unprocessable_entity, json: { errors: @meet_request.errors }
    end
  end

  private

  def request_params
    params.require(:request).permit(:priest_id, :status, :latitude, :longitude).tap do |wl|
      # Don't allow status for non-admin users
      wl.delete(:status) unless current_user.admin? || current_user.id == @meet_request.priest_id
    end
  end

  def set_meet_request
    @meet_request = MeetRequest.find(params[:id])
  end
end
