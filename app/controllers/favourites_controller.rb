# Favourites are intentionally available to anonymous visitors: the app has no
# user accounts and every action reads or writes only the caller's own session.
class FavouritesController < ApplicationController
  def index
    @articles = favourite_list.articles
  end

  # Adds one article (params[:article_id], from the article page) or several
  # (params[:article_ids][], from the articles list) to the favourites.
  def create
    single_id = params[:article_id].is_a?(String) ? params[:article_id] : nil
    selected = single_id.present? ? [single_id] : selected_article_ids

    if selected.reject(&:blank?).empty?
      flash[:alert] = 'Select at least one article to add to your favourites.'
    else
      added = favourite_list.add(selected)
      flash[:notice] = "#{view_context.pluralize(added, 'article')} added to your favourites." if added > 0
      if favourite_list.full?
        flash[:alert] = "Your favourites list is full (#{FavouriteList::MAX_SIZE} articles). Remove some to add more."
      elsif added == 0
        flash[:alert] = 'The selected articles are already in your favourites.'
      end
    end

    redirect_to_article_or(articles_path, single_id)
  end

  def destroy
    if favourite_list.remove(params[:id])
      flash[:notice] = 'Article removed from your favourites.'
    else
      flash[:alert] = 'That article was not in your favourites.'
    end

    if params[:return_to] == 'article'
      redirect_to_article_or(favourites_path, params[:id])
    else
      redirect_to favourites_path
    end
  end

  private

    # Only accept an array of scalar ids; anything else is ignored.
    def selected_article_ids
      ids = params[:article_ids]
      ids.is_a?(Array) ? ids.select { |id| id.is_a?(String) } : []
    end

    def redirect_to_article_or(fallback, raw_id)
      id = FavouriteList.parse_id(raw_id)
      if id && Article.exists?(id)
        redirect_to article_path(id)
      else
        redirect_to fallback
      end
    end
end
