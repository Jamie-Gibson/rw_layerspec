module V1
  class LayersController < ApplicationController
    before_action :basic_auth, only: [:update, :create, :destroy]
    before_action :set_layer,  only: [:show, :update, :destroy]

    def index
      @layers = Layer.fetch_all(layer_type_filter)
      render json: @layers, each_serializer: LayerSerializer, root: false
    end

    def show
      render json: @layer, serializer: LayerSerializer, root: false
    end

    def update
      if @layer.update(layer_params)
        render json: @layer, status: 200, serializer: LayerSerializer, root: false
      else
        render json: { success: false, message: @layer.errors }, status: 422
      end
    end

    def create
      @layer = Layer.new(layer_params)
      if @layer.save
        render json: @layer, status: 201, serializer: LayerSerializer, root: false
      else
        render json: { success: false, message: @layer.errors }, status: 422
      end
    end

    def destroy
      @layer.destroy
      begin
        render json: { message: 'Layer deleted' }, status: 200
      rescue ActiveRecord::RecordNotDestroyed
        return render json: @layer.erors, message: 'Layer could not be deleted', status: 422
      end
    end

    def docs
      @docs = YAML.load(File.read('lib/files/swagger.yml')).to_json
      render json: @docs
    end

    def info
      @docs = Oj.load(File.read('lib/files/service.json'))
      render json: @docs
    end

    private

      def set_layer
        @layer = Layer.find_by_id_or_slug(params[:id])
      end

      def layer_type_filter
        params.permit(:status, :published, :app)
      end

      def layer_params
        params.require(:layer).permit!
      end
  end
end
