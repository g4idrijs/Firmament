package firmament.core;

import firmament.core.FEntity;
import firmament.component.base.FEntityComponent;
import firmament.component.base.FEntityComponentFactory;
import firmament.util.loader.FDataLoader;
import firmament.core.FObject;
import firmament.core.FConfig;
class FEntityFactory{

	public static function createEntity(config:Dynamic,?gameInstanceName:String='main'):FEntity{
		var entity:FEntity;
		if(Std.is(config,String)){
			//pool support
			var str:String = config;
			//if string starts with "pool:" then get the entity from the specified pool
			if(str.indexOf("pool:") == 0){
				str = str.substr(5);
				return FGame.getInstance(gameInstanceName).getPoolManager().getPool(str).getEntity();
			}
			config = FDataLoader.loadData(str);
		}
		
		if(Std.is(config.className, String)){
			var c =Type.resolveClass(config.className);
			if(c==null){
				throw "class "+config.className+" could not be found. Did you remember to include the whole package name?";
			}
			entity = Type.createInstance(c,[config,gameInstanceName]);
		} else {
			entity = new FEntity(config,gameInstanceName);
		}
		applyComponents(entity,config);
        entity.registerComponentProperties();
        applyProperties(entity, config);
		initComponents(entity,config);

        for(c in entity.getAllComponents()){
            c.afterInit();
        }
		entity.trigger(new FEvent(FEntity.COMPONENTS_INITIALIZED));
		return entity;
	}


	public static function applyComponents(entity:FEntity, config:Dynamic){
		if(config.components == null){
			throw("no components specified in entity config.");
		}

        if(Std.is(config.components, Array) ){
            var ca:Array<Dynamic> = cast config.components;
            for(cConfig in ca){
                var component = FEntityComponentFactory.createComponent(cConfig.componentName);
                component.setConfig(cConfig);
                entity.setComponent(component);
            }
        }
        else{
            for(componentKey in Reflect.fields(config.components)){
                var cConfig= Reflect.field(config.components,componentKey);
                var component = FEntityComponentFactory.createComponent(cConfig.componentName,componentKey);
                component.setConfig(cConfig);
                entity.setComponent(component);
            }
        }
		
	}


	public static function initComponents(entity:FEntity, config:Dynamic){
		for(component in entity.getAllComponents()){
			component.init(component.getConfig());
		}
	}

	public static function applyProperties(entity:FEntity, config:FConfig){
        
		if(config.hasField('properties')){
            var props:FConfig = config.get('properties');
			for (key in props.fields()){
                var property = entity.getProperty(key);
                firmament.util.FLog.debug(props.get(key,property.type));
				entity.setProp(key,props.get(key,property.type));
			}
		}
	}

}


