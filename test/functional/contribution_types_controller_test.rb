require 'test_helper'

class ContributionTypesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:contribution_types)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_contribution_type
    assert_difference('ContributionType.count') do
      post :create, :contribution_type => { }
    end

    assert_redirected_to contribution_type_path(assigns(:contribution_type))
  end

  def test_should_show_contribution_type
    get :show, :id => contribution_types(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => contribution_types(:one).id
    assert_response :success
  end

  def test_should_update_contribution_type
    put :update, :id => contribution_types(:one).id, :contribution_type => { }
    assert_redirected_to contribution_type_path(assigns(:contribution_type))
  end

  def test_should_destroy_contribution_type
    assert_difference('ContributionType.count', -1) do
      delete :destroy, :id => contribution_types(:one).id
    end

    assert_redirected_to contribution_types_path
  end
end
