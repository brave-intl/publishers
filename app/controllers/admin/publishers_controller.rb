class Admin::PublishersController < AdminController
  def index
    @publishers = Publisher
    if params[:q].present?
      # Returns an ActiveRecord::Relation of publishers for pagination
      @publishers = Publisher.where("publishers.id IN (#{sql(params[:q])})").distinct
    end
    @publishers = @publishers.paginate(page: params[:page])
  end
end

private

# Returns an array of publisher ids that match the query
def sql(query)
  %{SELECT publishers.id 
    FROM   publishers 
           INNER JOIN(SELECT channels.* 
                      FROM   channels 
                             INNER JOIN site_channel_details 
                                     ON site_channel_details.id = channels.details_id 
                                        AND channels.details_type = 'SiteChannelDetails' 
                                        AND site_channel_details.brave_publisher_id ILIKE '%#{query}%' 
                      UNION ALL 
                      SELECT channels.* 
                      FROM   channels 
                             INNER JOIN youtube_channel_details 
                                     ON youtube_channel_details.id = 
                                        channels.details_id 
                                        AND youtube_channel_details.title ILIKE '%#{query}%' 
                      UNION ALL 
                      SELECT channels.* 
                      FROM   channels 
                             INNER JOIN twitch_channel_details 
                                     ON twitch_channel_details.id = channels.details_id 
                                        AND twitch_channel_details.NAME ILIKE '%#{query}%') 
                                       c 
                   ON c.publisher_id = publishers.id
    UNION ALL
    SELECT publishers.id
    FROM publishers
    WHERE publishers.email ILIKE '%#{query}%'
          OR publishers.name ILIKE '%#{query}%'}
end