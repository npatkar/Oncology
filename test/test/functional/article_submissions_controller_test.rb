require 'test_helper'

class ArticleSubmissionsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:article_submissions)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_article_submission
    assert_difference('ArticleSubmission.count') do
      post :create, :article_submission => { }
    end

    assert_redirected_to article_submission_path(assigns(:article_submission))
  end

  def test_should_show_article_submission
    get :show, :id => article_submissions(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => article_submissions(:one).id
    assert_response :success
  end

  def test_should_update_article_submission
    put :update, :id => article_submissions(:one).id, :article_submission => { }
    assert_redirected_to article_submission_path(assigns(:article_submission))
  end

  def test_should_destroy_article_submission
    assert_difference('ArticleSubmission.count', -1) do
      delete :destroy, :id => article_submissions(:one).id
    end

    assert_redirected_to article_submissions_path
  end
end
