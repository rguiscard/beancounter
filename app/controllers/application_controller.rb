class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :authenticate_user!

  around_action :switch_locale

  def switch_locale(&action)
    locale = current_user.try(:locale) || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

end
