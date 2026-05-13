alias Sendit.Repo
alias Sendit.Accounts.User
import Ecto.Changeset

users = [
  %{full_name: "Luka Tchelidze", username: "null_logic_0", email: "luka@sendit.com"},
  %{full_name: "Jeremy Fragrance", username: "jeremyfragrance", email: "jeremy@sendit.com"},
  %{full_name: "MrBeast", username: "mrbeast", email: "mrbeast@sendit.com"},
  %{full_name: "Khaby Lame", username: "khaby", email: "khaby@sendit.com"},
  %{full_name: "Charli D'Amelio", username: "charli", email: "charli@sendit.com"},
  %{full_name: "Bella Poarch", username: "bellapoarch", email: "bella@sendit.com"},
  %{full_name: "Logan Paul", username: "loganpaul", email: "logan@sendit.com"},
  %{full_name: "Jake Paul", username: "jakepaul", email: "jake@sendit.com"},
  %{full_name: "Andrew Tate", username: "cobratate", email: "tate@sendit.com"},
  %{full_name: "IShowSpeed", username: "speed", email: "speed@sendit.com"},
  %{full_name: "Kai Cenat", username: "kaicenat", email: "kai@sendit.com"},
  %{full_name: "Adin Ross", username: "adinross", email: "adin@sendit.com"},
  %{full_name: "David Dobrik", username: "daviddobrik", email: "david@sendit.com"},
  %{full_name: "Emma Chamberlain", username: "emmachamberlain", email: "emma@sendit.com"},
  %{full_name: "NikkieTutorials", username: "nikkie", email: "nikkie@sendit.com"},
  %{full_name: "PewDiePie", username: "pewdiepie", email: "felix@sendit.com"},
  %{full_name: "Marques Brownlee", username: "mkbhd", email: "mkbhd@sendit.com"},
  %{full_name: "Cristiano Ronaldo", username: "cr7", email: "cr7@sendit.com"},
  %{full_name: "Lionel Messi", username: "messi", email: "messi@sendit.com"},
  %{full_name: "Selena Gomez", username: "selenagomez", email: "selena@sendit.com"},
  %{full_name: "Kim Kardashian", username: "kimk", email: "kim@sendit.com"},
  %{full_name: "Ian Somerhalder", username: "iansomerhalder", email: "ian@sendit.com"},
  %{full_name: "Nina Dobrev", username: "ninadobrev", email: "nina@sendit.com"},
  %{full_name: "Paul Wesley", username: "paulwesley", email: "paul@sendit.com"},
  %{full_name: "Elon Musk", username: "elonmusk", email: "elon@sendit.com"},
  %{full_name: "Mark Zuckerberg", username: "zuck", email: "zuckerberg@sendit.com"},
  %{full_name: "Larry Page", username: "larrypage", email: "larry@sendit.com"},
  %{full_name: "Sam Altman", username: "sama", email: "sam@sendit.com"},
  %{full_name: "Jeff Bezos", username: "jeffbezos", email: "jeff@sendit.com"},
  %{full_name: "Bill Gates", username: "billgates", email: "bill@sendit.com"},
  %{full_name: "Ana de Armas", username: "anadearmas", email: "ana@sendit.com"},
  %{full_name: "Sydney Sweeney", username: "sydneysweeney", email: "sydney@sendit.com"}
]

Enum.each(users, fn user ->
  encoded_name = URI.encode(user.full_name)

  avatar =
    "https://api.dicebear.com/9.x/adventurer/svg?seed=#{URI.encode(encoded_name)}"

  %User{}
  |> change(%{
    full_name: user.full_name,
    email: user.email,
    username: user.username,
    avatar: avatar
  })
  |> unique_constraint(:email)
  |> Repo.insert!(on_conflict: :nothing)
end)

IO.puts("✅ Seeded #{length(users)} users")
