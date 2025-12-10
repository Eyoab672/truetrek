namespace :places do
  desc "Merge duplicate places with same title (case-insensitive) and address"
  task merge_duplicates: :environment do
    ActiveRecord::Base.transaction do
      # Find all duplicate groups (case-insensitive title, exact address)
      duplicates = Place.select("LOWER(TRIM(title)) as normalized_title, address")
                        .group("LOWER(TRIM(title)), address")
                        .having("COUNT(*) > 1")

      duplicates.each do |dup|
        places = Place.where("LOWER(TRIM(title)) = ? AND address = ?", dup.normalized_title, dup.address).to_a
        # Sort: most comments first, then by lowest id
        places.sort_by! { |p| [-p.comments.count, p.id] }

        # Keep the first one (most comments or lowest id)
        keeper = places.first
        to_remove = places[1..]

        puts "Merging duplicates for '#{dup.normalized_title}'"
        puts "  Keeping: ID #{keeper.id} (#{keeper.comments.count} comments)"

        to_remove.each do |place|
          puts "  Removing: ID #{place.id} (#{place.comments.count} comments)"

          # Move comments to keeper
          place.comments.update_all(place_id: keeper.id)

          # Move travel book associations
          TravelBookPlace.where(place_id: place.id).find_each do |tbp|
            # Only move if not already associated
            unless TravelBookPlace.exists?(travel_book_id: tbp.travel_book_id, place_id: keeper.id)
              tbp.update!(place_id: keeper.id)
            else
              tbp.destroy
            end
          end

          # Delete the duplicate place
          place.reload.destroy!
        end

        # Recount comments if counter cache exists
        if keeper.class.column_names.include?("comments_count")
          Place.reset_counters(keeper.id, :comments)
        end
      end

      puts "Done merging duplicates!"
    end
  end
end
