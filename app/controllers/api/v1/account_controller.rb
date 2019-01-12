# frozen_string_literal: true

# API for current user account info
class Api::V1::AccountController < ApiController
  before_action :set_account, only: [:show, :update]

  # GET /accounts
  def show
    render_success(UserSerializer.new(@account).as_json)
  end

  # PATCH/PUT /accounts/1
  def update
    if @account.update(user_params)
      render_success(@account)
    else
      render_error(
        RESPONSE_CODE[:unprocessable_entity],
        @account.errors.full_messages.join(","),
        @account.errors
      )
    end
  end

  # gets roles from frontend
  def roles
    get_user_from_sub
    render_success(roles: @user.team_context)
  end

  # changes teams from fronte
  def change_team
    get_user_from_sub
    if params[:team_id].nil?
      render_error RESPONSE_CODE[:unauthorized], I18n.t("api.errors.no_member"), ""
      return
    end

    render_success(roles: @user.team_context(params[:team_id]))
  end

  # TODO
  # DELETE /accounts/1
  # def destroy
  #   @event.destroy
  #   render_success(success: true, message: "Account was destroyed")
  # end

  private

  def get_user_from_sub
    email = parse_user_identify
    @user = User.find_by!(email: email)
    logger.debug("get roles")
    if @user != current_user
      logger.debug("user != current user")
      render_error RESPONSE_CODE[:unauthorized], I18n.t("api.errors.session.invalid"), ""
      return
    end
  end

  def set_account
    @account = current_user
  end

  def user_params
    params.require(:account).permit(:first_name, :last_name, :email, :password, :confirm_password, :group_id)
  end
end
