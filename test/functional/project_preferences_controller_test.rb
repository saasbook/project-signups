require 'test_helper'

class ProjectPreferencesControllerTest < ActionController::TestCase
  setup do
    @project_preference = project_preferences(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:project_preferences)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project_preference" do
    assert_difference('ProjectPreference.count') do
      post :create, project_preference: @project_preference.attributes
    end

    assert_redirected_to project_preference_path(assigns(:project_preference))
  end

  test "should show project_preference" do
    get :show, id: @project_preference.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @project_preference.to_param
    assert_response :success
  end

  test "should update project_preference" do
    put :update, id: @project_preference.to_param, project_preference: @project_preference.attributes
    assert_redirected_to project_preference_path(assigns(:project_preference))
  end

  test "should destroy project_preference" do
    assert_difference('ProjectPreference.count', -1) do
      delete :destroy, id: @project_preference.to_param
    end

    assert_redirected_to project_preferences_path
  end
end
