class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_action :create_new_form, only: [:new, :create]
  before_action :create_edit_form, only: [:edit, :update]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
  end

  # GET /projects/new
  def new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project_form.submit(project_params)

    respond_to do |format|
      if @project_form.save
        format.html { redirect_to @project_form, notice: "Project: #{@project_form.name} was successfully created." }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    @project_form.submit(project_params)

    respond_to do |format|
      if @project_form.save
        format.html { redirect_to @project_form, notice: "Project: #{@project_form.name} was successfully updated." }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    name = @project.name

    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: "Project: #{name} was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    def create_new_form
      project = Project.new
      @project_form = ProjectForm.new(project)
    end

    def create_edit_form
      @project_form = ProjectForm.new(@project)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:name, tasks_attributes: [:id, :name, :_destroy])
    end
end
