class ConferencesController < ApplicationController
  before_action :set_conference, only: [:show, :edit, :update, :destroy]
  before_action :create_new_form, only: [:new, :create]
  before_action :create_edit_form, only: [:edit, :update]

  # GET /conferences
  # GET /conferences.json
  def index
    @conferences = Conference.all
  end

  # GET /conferences/1
  # GET /conferences/1.json
  def show
  end

  # GET /conferences/new
  def new
  end

  # GET /conferences/1/edit
  def edit
  end

  # POST /conferences
  # POST /conferences.json
  def create
    @conference_form.submit(conference_params)

    respond_to do |format|
      if @conference_form.save
        format.html { redirect_to @conference_form, notice: "Conference: #{@conference_form.name} was successfully created." }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /conferences/1
  # PATCH/PUT /conferences/1.json
  def update
    @conference_form.submit(conference_params)

    respond_to do |format|
      if @conference_form.save
        format.html { redirect_to @conference_form, notice: "Conference: #{@conference_form.name} was successfully updated." }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /conferences/1
  # DELETE /conferences/1.json
  def destroy
    name = @conference.name

    @conference.destroy
    respond_to do |format|
      format.html { redirect_to conferences_url, notice: "Conference: #{name} was successfully destroyed." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_conference
      @conference = Conference.find(params[:id])
    end

    def create_new_form
      conference = Conference.new
      @conference_form = ConferenceForm.new(conference)
    end

    def create_edit_form
      @conference_form = ConferenceForm.new(@conference)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def conference_params
      params.require(:conference).permit(:name, :city, speaker_attributes: [:id, :name, :occupation, 
        presentations_attributes: [:id, :_destroy, :topic, :duration]])
    end
end
