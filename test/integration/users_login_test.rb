require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  # test "login with valid email/invalid password" do
  #   get login_path
  #   assert_template 'sessions/new'
  #   post login_path, params: { session: { email: @user.email, password: "invalidpassword" } }
  #   assert_not is_logged_in?
  #   assert_response :unprocessable_entity
  #   assert_template 'sessions/new'
  #   assert_not flash.empty?
  #   get root_path
  #   assert flash.empty?
  # end

  # test "login with valid information followed by logout" do
  #   post login_path, params: { session: { email: @user.email, password: 'password' } }

  #   assert is_logged_in?
  #   assert_redirected_to @user
  #   follow_redirect!
  #   assert_template 'users/show'
  #   assert is_logged_in?
  #   assert_select "a[href=?]", login_path, count: 0
  #   assert_select "a[href=?]", logout_path
  #   assert_select "a[href=?]", user_path(@user)
  #   delete logout_path
  #   assert_not is_logged_in?
  #   assert_response :see_other
  #   assert_redirected_to root_url
  #   follow_redirect!
  #   assert_select "a[href=?]", login_path
  #   assert_select "a[href=?]", logout_path, count:0
  #   assert_select "a[href=?]", user_path(@user), count:0
  # end

  class InvalidPasswordTest < UsersLoginTest

    test "login path" do
      get login_path
      assert_template 'sessions/new'
    end
  
    test "login with valid email/invalid password" do
      post login_path, params: { session: { email:    @user.email,
                                            password: "invalid" } }
      assert_not is_logged_in?
      assert_template 'sessions/new'
      assert_not flash.empty?
      get root_path
      assert flash.empty?
    end
  end
end
class ValidLogin < UsersLoginTest

  def setup
    super
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
  end
end

class ValidLoginTest < ValidLogin

  test "valid login" do
    assert is_logged_in?
    assert_redirected_to @user
  end

  test "redirect after login" do
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end
end

class Logout < ValidLogin

  def setup
    super
    delete logout_path
  end
end

class LogoutTest < Logout

  test "successful logout" do
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_url
  end

  test "redirect after logout" do
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "should still work after logout in second window" do
    delete logout_path
    assert_redirected_to root_url
  end
end

class RememberingTest < UsersLoginTest
  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    assert_equal @user.id, assigns(:user).id
  end

  test "login without remembering" do
    log_in_as(@user, remember_me: '1')
    delete logout_path
    log_in_as(@user, remember_me: '0')
    assert_empty cookies[:remember_token]
  end
end