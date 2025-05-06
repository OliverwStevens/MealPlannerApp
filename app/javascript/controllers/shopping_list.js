
document.addEventListener('turbolinks:load', function() {
    initShoppingList();
  });
  
  function initShoppingList() {
    // Save checked state to localStorage
    const checkboxes = document.querySelectorAll('#shopping-list input[type="checkbox"]');
    checkboxes.forEach(checkbox => {
      const itemId = checkbox.id;
      
      // Restore checked state from localStorage
      const savedState = localStorage.getItem(itemId);
      if (savedState === 'checked') {
        checkbox.checked = true;
        checkbox.closest('li').classList.add('text-gray-400');
      }
      
      // Save state when changed
      checkbox.addEventListener('change', function() {
        if (this.checked) {
          localStorage.setItem(itemId, 'checked');
          this.closest('li').classList.add('text-gray-400');
        } else {
          localStorage.setItem(itemId, 'unchecked');
          this.closest('li').classList.remove('text-gray-400');
        }
      });
    });
    
    // Add ability to sort ingredients by category (basic implementation)
    const sortButton = document.getElementById('sort-ingredients');
    if (sortButton) {
      sortButton.addEventListener('click', function() {
        const list = document.getElementById('shopping-list');
        const items = Array.from(list.querySelectorAll('li'));
        
        // Simple category detection (this could be enhanced with a proper categorization system)
        const categories = {
          produce: ['apple', 'banana', 'lettuce', 'tomato', 'onion', 'garlic', 'potato', 'carrot', 'pepper', 'cucumber', 'spinach', 'kale', 'fruit', 'vegetable'],
          dairy: ['milk', 'cheese', 'yogurt', 'butter', 'cream', 'egg'],
          meat: ['chicken', 'beef', 'pork', 'fish', 'turkey', 'lamb', 'sausage', 'bacon'],
          pantry: ['flour', 'sugar', 'salt', 'pepper', 'oil', 'vinegar', 'spice', 'herb', 'rice', 'pasta', 'bean', 'can', 'sauce', 'bread'],
          other: []
        };
        
        // Sort function that categorizes items
        items.sort((a, b) => {
          const nameA = a.querySelector('.ingredient-name').textContent.toLowerCase();
          const nameB = b.querySelector('.ingredient-name').textContent.toLowerCase();
          
          // Determine category
          const categoryA = getCategoryForItem(nameA, categories);
          const categoryB = getCategoryForItem(nameB, categories);
          
          if (categoryA !== categoryB) {
            return Object.keys(categories).indexOf(categoryA) - Object.keys(categories).indexOf(categoryB);
          }
          
          // If same category, sort alphabetically
          return nameA.localeCompare(nameB);
        });
        
        // Re-append items in the new order
        items.forEach(item => list.appendChild(item));
        
        // Add category headers
        addCategoryHeaders(list, items, categories);
      });
    }
  }
  
  function getCategoryForItem(itemName, categories) {
    for (const [category, keywords] of Object.entries(categories)) {
      if (category === 'other') continue;
      
      for (const keyword of keywords) {
        if (itemName.includes(keyword)) {
          return category;
        }
      }
    }
    return 'other';
  }
  
  function addCategoryHeaders(list, items, categories) {
    // Remove existing headers
    document.querySelectorAll('.category-header').forEach(header => header.remove());
    
    // Group items by category
    const itemsByCategory = {};
    Object.keys(categories).forEach(cat => itemsByCategory[cat] = []);
    
    items.forEach(item => {
      const name = item.querySelector('.ingredient-name').textContent.toLowerCase();
      const category = getCategoryForItem(name, categories);
      itemsByCategory[category].push(item);
    });
    
    // Add headers and reorder
    list.innerHTML = '';
    Object.entries(itemsByCategory).forEach(([category, categoryItems]) => {
      if (categoryItems.length > 0) {
        const header = document.createElement('li');
        header.className = 'category-header font-bold text-lg mt-4 mb-2 text-blue-800';
        header.textContent = category.charAt(0).toUpperCase() + category.slice(1);
        list.appendChild(header);
        
        categoryItems.forEach(item => list.appendChild(item));
      }
    });
  }