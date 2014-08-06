class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

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
    @project = Project.new
    @project_form = ProjectForm.new(@project)
  end

  # GET /projects/1/edit
  def edit
    @project_form = ProjectForm.new(@project)
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new
    @project_form = ProjectForm.new(@project)

    @project_form.submit(project_params)

    respond_to do |format|
      if @project_form.save
        format.html { redirect_to @project_form, notice: 'Project was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    @project_form = ProjectForm.new(@project)

    @project_form.submit(project_params)

    respond_to do |format|
      if @project_form.save
        format.html { redirect_to @project_form, notice: 'Project was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:name, :owner_id, tasks_attributes: [ :name, :description, :done, :id, :_destroy,
      sub_tasks_attributes: [ :name, :description, :done, :id, :_destroy ] ],
      owner_attributes: [ :name, :role, :description, :id, :_destroy ],
        contributors_attributes: [ :name, :role, :description, :id, :_destroy ],
        project_tags_attributes: [ :tag_id, :id, :_destroy, tag_attributes:
          [ :name, :id, :_destroy ] ])
    end

end