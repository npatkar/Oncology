require 'test_helper'

class ContributionsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:contributions)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_contribution
    assert_difference('Contribution.count') do
      post :create, :contribution => { }
    end

    assert_redirected_to contribution_path(assigns(:contribution))
  end

  def test_should_show_contribution
    get :show, :id => contributions(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => contributions(:one).id
    assert_response :success
  end

  def test_should_update_contribution
    put :update, :id => contributions(:one).id, :contribution => { }
    assert_redirected_to contribution_path(assigns(:contribution))
  end

  def test_should_destroy_contribution
    assert_difference('Contribution.count', -1) do
      delete :destroy, :id => contributions(:one).id
    end

    assert_redirected_to contributions_path
  end
end
