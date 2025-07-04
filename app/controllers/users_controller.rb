class UsersController < ApplicationController
  include EncryptionHelper
  def edit
    @pending_seats = Current.user.pending_seats
  end

  def update
    # TODO: allow updating email, reconfirm address
    Current.user.assign_attributes(update_params)

    if Current.user.save
      redirect_back fallback_location: root_path, notice: "User updated!"
    else
      redirect_back fallback_location: root_path, alert: "Something went wrong."
    end
  end

  def confirm
    valid_token = valid_user_token(Current.user.email_address, confirm_params[:token], "email_confirm")
    valid_user = Current.user&.unconfirmed?

    valid_confirmation = valid_token && valid_user
    return redirect_to root_path, alert: "Something went wrong." unless valid_confirmation

    Current.user.confirmed_at = Time.zone.now

    if Current.user.save
      redirect_to root_path, notice: "Email confirmed!"
    else
      redirect_to root_path, alert: "Something went wrong."
    end
  end

  def reconfirm
    return redirect_back fallback_location: root_path, alert: "Something went wrong." unless Current&.user&.unconfirmed?

    EmailConfirmMailer.request_confirmation(user: Current.user).deliver_later
    redirect_back fallback_location: root_path, notice: "Confirmation email re-sent."
  end

  private

  def update_params
    params.require(:user).permit(:name)
  end

  def confirm_params
    params.permit(:token)
  end
end
