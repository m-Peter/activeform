class SurveysController < ApplicationController
  before_action :set_survey, only: [:show, :edit, :update, :destroy]
  before_action :create_new_form, only: [:new, :create]
  before_action :create_edit_form, only: [:edit, :update]

  # GET /surveys
  # GET /surveys.json
  def index
    @surveys = Survey.all
  end

  # GET /surveys/1
  # GET /surveys/1.json
  def show
  end

  # GET /surveys/new
  def new
  end

  # GET /surveys/1/edit
  def edit
  end

  # POST /surveys
  # POST /surveys.json
  def create
    @survey_form.submit(survey_params)

    respond_to do |format|
      if @survey_form.save
        format.html { redirect_to @survey_form, notice: "Survey: #{@survey_form.name} was successfully created." }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /surveys/1
  # PATCH/PUT /surveys/1.json
  def update
    @survey_form.submit(survey_params)

    respond_to do |format|
      if @survey_form.save
        format.html { redirect_to @survey_form, notice: "Survey: #{@survey_form.name} was successfully updated." }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /surveys/1
  # DELETE /surveys/1.json
  def destroy
    name = @survey.name

    @survey.destroy
    respond_to do |format|
      format.html { redirect_to surveys_url, notice: "Survey: #{name} was successfully destroyed." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_survey
      @survey = Survey.find(params[:id])
    end

    def create_new_form
      survey = Survey.new
      @survey_form = SurveyForm.new(survey)
    end

    def create_edit_form
      @survey_form = SurveyForm.new(@survey)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def survey_params
      params.require(:survey).permit(:name, questions_attributes: [:id, :_destroy, :content,
        answers_attributes: [:id, :_destroy, :content]])
    end
end
