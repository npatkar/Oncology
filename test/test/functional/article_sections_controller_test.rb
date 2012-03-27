require 'test_helper'

class ArticleSectionsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:article_sections)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_article_section
    assert_difference('ArticleSection.count') do
      post :create, :article_section => { }
    end

    assert_redirected_to article_section_path(assigns(:article_section))
  end

  def test_should_show_article_section
    get :show, :id => article_sections(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => article_sections(:one).id
    assert_response :success
  end

  def test_should_update_article_section
    put :update, :id => article_sections(:one).id, :article_section => { }
    assert_redirected_to article_section_path(assigns(:article_section))
  end

  def test_should_destroy_article_section
    assert_difference('ArticleSection.count', -1) do
      delete :destroy, :id => article_sections(:one).id
    end

    assert_redirected_to article_sections_path
  end
end
