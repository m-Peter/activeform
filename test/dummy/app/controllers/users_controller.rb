class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :create_new_form, only: [:new, :create]
  before_action :create_edit_form, only: [:edit, :update]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user_form.submit(user_params)

    respond_to do |format|
      if @user_form.save
        format.html { redirect_to @user_form, notice: "User: #{@user_form.name} was successfully created." }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @user_form.submit(user_params)

    respond_to do |format|
      if @user_form.save
        format.html { redirect_to @user_form, notice: "User: #{@user_form.name} was successfully updated." }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    name = @user.name
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: "User: #{name} was successfully destroyed." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def create_new_form
      user = User.new
      @user_form = UserForm.new(user)
    end

    def create_edit_form
      @user_form = UserForm.new(@user)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :age, :gender, email_attributes: [:id, :address],
        profile_attributes: [:id, :twitter_name, :github_name])
    end
end
