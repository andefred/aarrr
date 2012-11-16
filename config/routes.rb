AARRR::Engine.routes.draw do
	get "test" => Proc.new {|env| [200,{},["it works"]]}

	get "test/test2" => "test#test2"
end