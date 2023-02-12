defmodule ParkingPoolWeb.DevAuthController do
  use ParkingPoolWeb, :controller

  require Logger

  def login(conn, _) do
    length = 16
    random_user = :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
    claims = %{
      "oid" => "__DEV__#{random_user}",
      "name" => generate_name()
    }

    conn
    |> configure_session(renew: true)
    |> put_session(:user_claims, claims)
    |> redirect(to: "/")
  end

  def logout(conn, _) do
    conn
    |> configure_session(drop: true)
    |> clear_session()
    |> redirect(to: "/")
  end

  # Random name generator courtesy of ChatGPT
  @first_names ["Aino", "Eeva", "Ilmari", "Johanna", "Kalle", "Mikko", "Nina", "Olli", "Pekka", "Riikka",
    "Sari", "Tero", "Ulla", "Valtteri", "Waltteri", "Xenia", "Yrjö", "Zandra",
    "Aurora", "Birgitta", "Curt", "Diana", "Eero", "Fanni", "Gustav", "Hanna", "Iida", "Janne",
    "Kai", "Lotta", "Mari", "Niko", "Outi", "Pirkko", "Raimo", "Saara", "Teemu", "Urho"]
  @last_names ["Heikkinen", "Järvinen", "Kainulainen", "Lahti", "Mäkinen", "Niemi", "Ojala", "Peltonen", "Rantanen",
    "Saari", "Talli", "Ukkonen", "Virtanen", "Wahlsten", "Ylitalo", "Zetterberg",
    "Anttila", "Blomqvist", "Cederberg", "Dahlström", "Ekholm", "Forsman", "Granqvist", "Hakala", "Ilvonen", "Jokinen",
    "Karhu", "Laine", "Mustonen", "Nyman", "Östman", "Päivärinta", "Rönkkö", "Siitonen", "Tervonen", "Ukkonen"]
  def generate_name do
    "#{Enum.random(@first_names)} #{Enum.random(@last_names)}"
  end
end
