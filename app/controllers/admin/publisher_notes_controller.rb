module Admin
  class PublisherNotesController < AdminController
    before_action :authorize, except: :create

    def create
      publisher = Publisher.find(params[:publisher_id])
      admin = current_user

      note = PublisherNote.new(
        publisher: publisher,
        created_by: current_user,
        note: note_params[:note],
      )
      note.thread_id = note_params[:thread_id] if note_params[:thread_id].present?

      if note.save
        redirect_to(admin_publisher_path(publisher.id))
      else
       redirect_to admin_publisher_path(publisher.id), flash: { alert: note.errors.full_messages.join(',') }
      end
    end

    def update
      if @note.update(note_params)
        redirect_to admin_publisher_path(id: params[:publisher_id] ), flash: { success: "Successfully updated comment"}
      else
        redirect_to admin_publisher_path(id: params[:publisher_id]), flash: { alert: note.errors.full_messages }
      end
    end


    def destroy
      publisher = @note.publisher
      if @note.comments.any?
        redirect_to admin_publisher_path(publisher), flash: { alert: "Can't delete a note that has comments." }
      else
        @note.destroy

        redirect_to admin_publisher_path(publisher)
      end
    end

    private

    def authorize
      @note =  PublisherNote.find(params[:id])
      raise unless @note.created_by == current_user
    end

    def note_params
      params.require(:publisher_note).permit(:note, :thread_id)
    end
  end
end
