organization = [
  {name: 'club-laguna'},
  {name: 'barfritzn'},
  {name: 'la-leander'},
]

organization.each do |o|
  Organization.create(o)
end

users = [
  {email: 'info@club-laguna.de', password: 'Y29ja3RhaWw=', organization: Organization.find_by_name('club-laguna')},
  {email: 'matthias.wiesner@googlemail.com', password: 'dGVzdDEyMw==', organization: Organization.find_by_name('la-leander')}
]

users.each do |u|
  User.create(u)
end