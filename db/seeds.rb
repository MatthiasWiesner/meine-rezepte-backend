users = [
  {email: 'info@club-laguna.de', password: 'Y29ja3RhaWw='},
  {email: 'matthias.wiesner@googlemail.com', password: 'dGVzdDEyMw=='}
]

users.each do |u|
  User.create(u)
end