package br.com.demo.helpers;

import br.com.demo.model.Phonebook;
import br.com.demo.persistence.PhonebookPersistence;
import org.mockito.Mockito;

import java.util.List;

/**
 * Class responsible to create the mocks for testing.
 *
 * @author fvilarinho@gmail.com
 */
public abstract class Mocks{
    // Returns the mock for the persistence layer.
    public static PhonebookPersistence getPersistence(){
        return Mockito.mock(PhonebookPersistence.class);
    }
    
    // Returns the mock of list of items.
    public static List<Phonebook> getList(){
        return List.of(getItem());
    }
    
    // Returns the mock of item.
    public static Phonebook getItem(){
        Phonebook item = new Phonebook();
        
        item.setId(1);
        item.setName("Luke Skywalker");
        item.setPhone("366-117891");
        
        return item;
    }

    // Returns the mock of existing item.
    public static Phonebook getExistingItem(){
        Phonebook item = new Phonebook();
        
        item.setName("Luke Skywalker");
        item.setPhone("366-117891");
        
        return item;
    }
}
