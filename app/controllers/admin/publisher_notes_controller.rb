module Admin
  class PublisherNotesController < AdminController
    def create
      publisher = Publisher.find(params[:publisher_id])
      admin = current_user

      note = PublisherNote.new(
        publisher: publisher,
        created_by: current_user,
        note: note_params[:note],
      )
      note.thread_id = note_params[:thread_id] if note_params[:thread_id].present?

      note.save!
      if note_params[:thread_id].present?
        redirect_to(admin_publisher_path(publisher.id, anchor: "container_#{note_params[:thread_id]}"))
      else
        redirect_to(admin_publisher_path(publisher.id))
      end
    end

    def destroy
      note = PublisherNote.find(params[:id])
      raise unless note.created_by == current_user

      publisher = note.publisher
      note.destroy

      redirect_to admin_publisher_path(publisher)
    end

    private

    def note_params
      params.require(:publisher_note).permit(:note, :thread_id)
    end
  end
end
