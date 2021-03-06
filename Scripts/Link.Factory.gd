extends 'res://Scripts/Link.gd'

export(String) var container
export(String, MULTILINE) var products

var products_list = []

func _ready():
	
	if is_queued_for_deletion():
		return
	
	
	
	products = products.c_escape().replace('\\n', ' ')
#	products = products.strip_escapes()
	
	var new_product = {}
	var i = 0
	
	print(products)
	print(products.split(' ', false))
	
	for param in products.split(' ', false):
		
		if i == 0:
			new_product.target = param
		if i == 1:
			new_product.target_container = param
		if i == 3:
			new_product.amount = param
		if i == 4:
			new_product.item = param
		
		i = i + 1 
		if i > 4:
			i = 0
			products_list.append(new_product.duplicate())
			new_product = {}
	
	
	for product in products_list:
		
		if product.target == 'target':
			
			_create_product(get_node(from), container, product.amount, product.item)


func _create_product(target, target_container, amount, item):
	
	for i in range(amount):
		
		var new_actor = Meta.AddActor(item)
		
		Meta.CreateLink(target, new_actor, 'Contains', { 'container': target_container })
		
		for subproduct in products_list:
			
			#prints('asdf', subproduct.target.strip_edges(), product.item.strip_edges(), subproduct.target == product.item)
			
			if subproduct.target == item:
				
				_create_product(new_actor, subproduct.target_container, subproduct.amount, subproduct.item)