class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show, :edit, :update, :destroy]
  before_action :create_new_form, only: [:new, :create]
  before_action :create_edit_form, only: [:edit, :update]


  def index
    @assignments = Assignment.all
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    @assignment_form.submit(assignment_params)

    respond_to do |format|
      if @assignment_form.save
        format.html { redirect_to @assignment_form, notice: "Assignment: #{@assignment_form.name} was successfully created." }
      else
        format.html { render :new }
      end
    end
  end

  def update
    @assignment_form.submit(assignment_params)

    respond_to do |format|
      if @assignment_form.save
        format.html { redirect_to @assignment_form, notice: "Assignment: #{@assignment_form.name} was successfully updated." }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    name = @assignment.name

    @assignment.destroy
    respond_to do |format|
      format.html { redirect_to assignments_url, notice: "Assignment: #{name} was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      @assignment = Assignment.find(params[:id])
    end

    def create_new_form
      assignment = Assignment.new
      @assignment_form = AssignmentForm.new(assignment)
    end

    def create_edit_form
      @assignment_form = AssignmentForm.new(@assignment)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def assignment_params
      params.require(:assignment).permit(:name, tasks_attributes: [:id, :name, :_destroy])
    end
end