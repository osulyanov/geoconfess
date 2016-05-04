module Api
  module V1
    class FavoritesController < Api::V1::V1Controller
      before_action :doorkeeper_authorize!
      before_action :set_favorite, only: [:destroy]
      load_and_authorize_resource

      resource_description do
        short 'Favorites'
      end

      api! 'All favorites of current user'
      description <<-EOS
        ## Description
        All favorites of current_user.
        Priest has location attributes if he is active right now.
      EOS
      example <<-EOS
        [
          {
            "id": 1,
            "priest": {
              "id": 17,
              "name": "Oleg",
              "surname": "Test",
              "latitude": 55.3232123,
              "longitude": 80.234234
            }
          },
          {
            "id": 2,
            "priest": {
              "id": 17,
              "name": "Oleg",
              "surname": "Test"
            }
          }
        ]
      EOS

      def index
        @favorites = current_user.favorites
      end

      api! 'Create favorite'
      description <<-EOS
        ## Description
        Add priest to favorites
        Returns code 201 with favorite data if favorite successfully created.
      EOS
      param :favorite, Hash, desc: 'Favorite info', required: true do
        param :priest_id, Integer, desc: 'Priest ID', required: true
      end
      example <<-EOS
        {
          "id": 1,
          "priest": {
            "id": 17,
            "name": "Oleg",
            "surname": "Test",
            "latitude": 55.3232123,
            "longitude": 80.234234
          }
        }
      EOS

      def create
        @favorite = current_user.favorites.where(favorite_params).first_or_initialize
        if @favorite.save
          render :show, status: :created
        else
          render status: :unprocessable_entity, json: { errors: @favorite.errors }
        end
      end

      api! 'Destroy favorite'
      description <<-EOS
        ## Description
        Remove priest from favorites
        Returns code 200 with no content if favorite successfully destroyed.
      EOS

      def destroy
        if @favorite.destroy
          head status: :ok
        else
          render status: :unprocessable_entity, json: { errors: @favorite.errors }
        end
      end

      private

      def favorite_params
        params.require(:favorite).permit(:priest_id)
      end

      def set_favorite
        @favorite = Favorite.find_by(id: params[:id])
      end
    end
  end
end
