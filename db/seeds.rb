demo = User.find_or_create_by!(username: "demo") { |u| u.display_name = "Demo User" }

Post.destroy_all
Post.create!([
  { title: "Rails Guides", url: "https://guides.rubyonrails.org/", body: "Documentación oficial.", community: "programming", user: demo },
  { title: "Ruby Lang", url: "https://www.ruby-lang.org/", body: nil, community: "programming", user: demo }
])

puts "Seed OK: #{User.count} users, #{Post.count} posts."