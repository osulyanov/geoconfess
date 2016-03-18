class Api::V1::ChurchesController < Api::V1::V1Controller
  before_action :doorkeeper_authorize!
  before_action :set_church, only: [:show, :update, :destroy]
  load_and_authorize_resource

  resource_description do
    short 'Churches'
  end

  api! 'Churches list'
  description <<-EOS
    ## Description
    All available churches
  EOS
  example <<-EOS
    [
      {
        "id": 1,
        "name": "Test Church",
        "latitude": 55.3232,
        "longitude": 80.234234,
        "street": "Some street",
        "postcode": "453534534",
        "city": "Paris",
        "state": "PA",
        "country": "FR"
      }
    ]
  EOS

  def index
    @churches = Church.all
  end


  api! 'Show church'
  description <<-EOS
    ## Description
    Show church with certain ID
  EOS
  example <<-EOS
    {
      "id": 1,
      "name": "Test Church",
      "latitude": 55.3232,
      "longitude": 80.234234,
      "street": "Some street",
      "postcode": "453534534",
      "city": "Paris",
      "state": "PA",
      "country": "FR"
    }
  EOS

  def show
  end


  api :POST, '/churches', 'Create church'
  description <<-EOS
    ## Description
    Creates church. For admin and priest only.
    Returns code 201 with no content if church successfully created.
  EOS
  param :church, Hash, desc: 'Church info' do
    param :name, String, desc: 'Name', required: true
    param :latitude, Float, desc: 'Latitude', required: true
    param :longitude, Float, desc: 'Longitude', required: true
    param :street, String, desc: 'Street'
    param :postcode, String, desc: 'Postcode'
    param :city, String, desc: 'City'
    param :state, String, desc: 'State'
    param :country, String, desc: 'Country code (e.g. FR, GB, DE)'
  end

  def create
    @church = Church.new(church_params)
    if @church.save
      head status: :created
    else
      render status: :unprocessable_entity, json: { errors: @church.errors }
    end
  end


  api! 'Update church'
  description <<-EOS
    ## Description
    Updates church data. For admin only.
    Returns code 200 with no content if church successfully updated.
  EOS
  param :church, Hash, desc: 'Church info' do
    param :name, String, desc: 'Name', required: true
    param :latitude, Float, desc: 'Latitude', required: true
    param :longitude, Float, desc: 'Longitude', required: true
    param :street, String, desc: 'Street'
    param :postcode, String, desc: 'Postcode'
    param :city, String, desc: 'City'
    param :state, String, desc: 'State'
    param :country, String, desc: 'Country code (e.g. FR, GB, DE)'
  end

  def update
    if @church.update_attributes(church_params)
      head status: :ok
    else
      render status: :unprocessable_entity, json: { errors: @church.errors }
    end
  end


  api! 'Destroy church'
  description <<-EOS
    ## Description
    Destroys church. For admin only.
    Returns code 200 with no content if church successfully destroyed.
  EOS

  def destroy
    if @church.destroy
      head status: :ok
    else
      render status: :unprocessable_entity, json: { errors: @church.errors }
    end
  end

  private

  def church_params
    params.require(:church).permit(:name, :latitude, :longitude, :street,
                                   :postcode, :city, :state, :country)
  end

  def set_church
    @church = Church.find(params[:id])
  end
end
