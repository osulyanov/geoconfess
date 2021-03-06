module Api
  module V1
    class RecurrencesController < Api::V1::V1Controller
      before_action :doorkeeper_authorize!
      before_action :set_spot, only: [:index, :create]
      before_action :set_recurrence, only: [:show, :update, :destroy,
                                            :confirm_availability]
      before_action :set_priest, only: [:for_priest]
      load_and_authorize_resource

      resource_description do
        short 'Recurrences'
      end

      def_param_group :recurrence do
        param :recurrence, Hash, desc: 'Recurrence info', required: true do
          param :date, Date,
                desc: 'Date, format YYYY-MM-DD, only for sing-date recurrence',
                required: true
          param :start_at, Time, desc: 'Start time, format HH:MM',
                                 required: true
          param :stop_at, Time, desc: 'Stop time, format HH:MM', required: true
          param :week_days, Array, desc: 'Weekdays, Array like \["Tuesday",
                                          "Wednesday", "Thursday", "Friday"\],
                                          only for recurrent recurrence',
                                   required: true
        end
      end

      api! 'Recurrences list'
      description <<-EOS
        ## Description
        All available recurrences for this spot
      EOS
      example <<-EOS
        [
          {
            "id": 6,
            "spot_id": 4,
            "start_at": "10:00",
            "stop_at": "20:00",
            "week_days": [
              "Tuesday",
              "Wednesday",
              "Thursday",
              "Friday"
            ]
          }
        ]
      EOS

      def index
        @recurrences = @spot.recurrences
      end

      api! 'Show Recurrence'
      description <<-EOS
        ## Description
        Show recurrence with certain ID
      EOS
      example <<-EOS
        {
          "id": 5,
          "spot_id": 3,
          "date": "2016-02-25",
          "start_at": "10:00",
          "stop_at": "20:00",
        }
      EOS

      def show
      end

      api :POST, '/v1/spots/:spot_id/recurrences', 'Create recurrence'
      description <<-EOS
        ## Description
        Creates recurrence. For admin and priest only.
        Returns code 201 with recurrence data if recurrence successfully created.
      EOS
      param_group :recurrence
      example <<-EOS
        {
          "id": 5,
          "spot_id": 3,
          "date": "2016-02-25",
          "start_at": "10:00",
          "stop_at": "20:00",
        }
      EOS

      def create
        authorize! :update, @spot
        @recurrence = @spot.recurrences.new(recurrence_params)
        if @recurrence.save
          render :show, status: :created
        else
          render status: :unprocessable_entity,
                 json: { errors: @recurrence.errors }
        end
      end

      api! 'Update recurrence'
      description <<-EOS
        ## Description
        Updates recurrence data. For admin and priest only.
        Returns code 200 and {result: "success"} if recurrence successfully updated.
      EOS
      param_group :recurrence

      def update
        if @recurrence.update_attributes(recurrence_params)
          render status: :ok, json: { result: 'success' }
        else
          render status: :unprocessable_entity,
                 json: { errors: @recurrence.errors }
        end
      end

      api! 'Destroy recurrence'
      description <<-EOS
        ## Description
        Destroys recurrence. For priest and admin only.
        Returns code 200 with no content if recurrence successfully destroyed.
      EOS

      def destroy
        if @recurrence.destroy
          head status: :ok
        else
          render status: :unprocessable_entity,
                 json: { errors: @recurrence.errors }
        end
      end

      api! 'Recurrences of the priest'
      description <<-EOS
        ## Description
        All recurrences for passed priest
      EOS
      param :priest_id, Integer, desc: 'Priest ID', required: true
      example <<-EOS
        [
          {
            "name": "Active right now",
            "start_at": "10:00",
            "stop_at": "20:00",
            "date": "25/03/2016"
          }
        ]
      EOS

      def for_priest
        spot_ids = @priest.spot_ids
        @recurrences = Recurrence.in_the_future.where(spot_id: spot_ids)
      end

      api! 'Confirm priest availability'
      description <<-EOS
        ## Description
        Confirm priest availability for the recurrence for today.
        Returns code 200 with no content if recurrence successfully updated.
      EOS

      def confirm_availability
        if @recurrence.confirm_availability!
          head status: :ok
        else
          render status: :unprocessable_entity,
                 json: { errors: @recurrence.errors }
        end
      end

      private

      def recurrence_params
        params.require(:recurrence).permit(:date, :start_at, :stop_at, :days,
                                           week_days: [])
      end

      def set_spot
        @spot = Spot.find_by(id: params[:spot_id] || params[:id])
      end

      def set_recurrence
        @recurrence = Recurrence.find_by(id: params[:id])
      end

      def set_priest
        @priest = User.active.priests.find_by(id: params[:priest_id])
      end
    end
  end
end
