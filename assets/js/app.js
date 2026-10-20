/**
 * ROCK & STONE RESTAURANT 2.0 — GLOBAL CLIENT LOGIC
 * Strict 100% Pure Vegetarian Restaurant
 * Location: Tatal, Nurpur, Kangra, HP
 */

const ROCK_STONE = (function () {
  'use strict';

  // Config
  const RESTAURANT_INFO = {
    name: 'Rock & Stone Restaurant',
    tagline: '100% Pure Vegetarian Himalayan Hospitality',
    address: 'V.P.O. Tatal, Near Indian Oil Petrol Pump, P/O Khel, Tehsil Nurpur, Kangra, Himachal Pradesh 176205',
    phone: '+91 76781 29577',
    email: 'ashmitkumarbwj@gmail.com',
    fssai: '10925004000220',
    gstin: '02DKLPP2797H1ZR',
    hours: 'Mon–Sun: 10:00 AM – 10:30 PM (Dine-in till 10:00 PM)'
  };

  // Safe vegetarian menu catalog (Sample preview data, strictly pure vegetarian, marked as pending owner validation)
  const SAMPLE_MENU = [
    {
      id: 'veg-01',
      name: 'Kangra Madra (Himachali Speciality)',
      category: 'Himachali Specialties',
      price: 280,
      description: 'Slow-cooked white chickpeas in rich spiced curd gravy, infused with cardamom, cloves, and whole spices.',
      image: 'assets/images/pure-veg-thali.jpg',
      is_pure_veg: true,
      is_featured: true,
      dietary: ['Gluten-Free', 'Traditional']
    },
    {
      id: 'veg-02',
      name: 'Clay Tandoor Paneer Tikka',
      category: 'Tandoor & Starters',
      price: 320,
      description: 'Fresh Himalayan paneer cubes marinated in rich Kashmiri spices and mustard oil, roasted to smoky perfection in clay oven.',
      image: 'assets/images/paneer-tikka.jpg',
      is_pure_veg: true,
      is_featured: true,
      dietary: ['High Protein', 'Gluten-Free']
    },
    {
      id: 'veg-03',
      name: 'Dal Dhauladhar (Signature Dal Makhani)',
      category: 'Main Course',
      price: 260,
      description: 'Whole black lentils slow simmered overnight with fresh churned butter and mountain cream.',
      image: 'assets/images/pure-veg-thali.jpg',
      is_pure_veg: true,
      is_featured: true,
      dietary: ['Rich & Creamy']
    },
    {
      id: 'veg-04',
      name: 'Sepu Vadi in Spinach Gravy',
      category: 'Himachali Specialties',
      price: 290,
      description: 'Traditional split-urad dumplings prepared in steamed curd & mild aromatic spinach gravy.',
      image: 'assets/images/pure-veg-thali.jpg',
      is_pure_veg: true,
      is_featured: true,
      dietary: ['Traditional Recipe']
    },
    {
      id: 'veg-05',
      name: 'Paneer Butter Masala',
      category: 'Main Course',
      price: 310,
      description: 'Soft cottage cheese simmered in a velvety tomato-cashew satin gravy with fragrant fenugreek.',
      image: 'assets/images/pure-veg-thali.jpg',
      is_pure_veg: true,
      is_featured: false,
      dietary: ['House Favorite']
    },
    {
      id: 'veg-06',
      name: 'Kashmiri Dum Aloo',
      category: 'Main Course',
      price: 240,
      description: 'Baby potatoes par-boiled, fried crisp and simmered in a ginger-fennel scented gravy without onion or garlic.',
      image: 'assets/images/pure-veg-thali.jpg',
      is_pure_veg: true,
      is_featured: false,
      dietary: ['No Onion Garlic', 'Jain Option Available']
    },
    {
      id: 'veg-07',
      name: 'Butter Naan / Tandoori Roti Basket',
      category: 'Breads',
      price: 140,
      description: 'Assortment of freshly baked crisp tandoori roti and flaky butter naan from our clay oven.',
      image: 'assets/images/pure-veg-thali.jpg',
      is_pure_veg: true,
      is_featured: false,
      dietary: ['Clay Tandoor']
    },
    {
      id: 'veg-08',
      name: 'Himalayan Herbal Masala Chai',
      category: 'Beverages',
      price: 60,
      description: 'Kangra valley organic tea brewed with lemongrass, mulethi, green cardamom, and fresh mountain mint.',
      image: 'assets/images/hero-himalayas.jpg',
      is_pure_veg: true,
      is_featured: false,
      dietary: ['Organic Tea']
    }
  ];

  // Cart Management
  class CartManager {
    constructor() {
      this.items = this.loadCart();
      this.listeners = [];
    }

    loadCart() {
      try {
        const stored = localStorage.getItem('rs_cart_items');
        return stored ? JSON.parse(stored) : [];
      } catch (e) {
        console.error('Cart load error', e);
        return [];
      }
    }

    saveCart() {
      try {
        localStorage.setItem('rs_cart_items', JSON.stringify(this.items));
      } catch (e) {
        console.error('Cart save error', e);
      }
      this.notifyListeners();
    }

    addListener(fn) {
      this.listeners.push(fn);
    }

    notifyListeners() {
      this.listeners.forEach(fn => fn(this.items));
      this.updateHeaderBadge();
    }

    addItem(dish, quantity = 1) {
      if (!dish.is_pure_veg) {
        throw new Error('Violates 100% Pure Vegetarian policy');
      }
      const existing = this.items.find(i => i.id === dish.id);
      if (existing) {
        existing.quantity += quantity;
      } else {
        this.items.push({
          id: dish.id,
          name: dish.name,
          price: Number(dish.price),
          image: dish.image,
          quantity: quantity,
          is_pure_veg: true
        });
      }
      this.saveCart();
      showToast(`Added "${dish.name}" to cart`, 'success');
    }

    updateQuantity(dishId, quantity) {
      const idx = this.items.findIndex(i => i.id === dishId);
      if (idx !== -1) {
        if (quantity <= 0) {
          const removedName = this.items[idx].name;
          this.items.splice(idx, 1);
          showToast(`Removed "${removedName}" from cart`, 'info');
        } else {
          this.items[idx].quantity = quantity;
        }
        this.saveCart();
      }
    }

    clearCart() {
      this.items = [];
      this.saveCart();
    }

    getSubtotal() {
      return this.items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    }

    getTotalCount() {
      return this.items.reduce((sum, item) => sum + item.quantity, 0);
    }

    updateHeaderBadge() {
      const badgeEls = document.querySelectorAll('.cart-badge');
      const count = this.getTotalCount();
      badgeEls.forEach(el => {
        el.textContent = count;
        el.style.display = count > 0 ? 'flex' : 'none';
      });
    }
  }

  const cart = new CartManager();

  // Toast System
  function showToast(message, type = 'info') {
    let container = document.getElementById('toast-container');
    if (!container) {
      container = document.createElement('div');
      container.id = 'toast-container';
      container.className = 'toast-container';
      document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    toast.className = `toast ${type === 'success' ? 'toast-success' : type === 'error' ? 'toast-error' : ''}`;
    toast.innerHTML = `
      <div class="toast-icon">
        ${type === 'success' ? '🌿' : type === 'error' ? '⚠️' : 'ℹ️'}
      </div>
      <div class="toast-msg">${message}</div>
    `;

    container.appendChild(toast);
    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translateY(10px)';
      toast.style.transition = 'all 0.3s ease';
      setTimeout(() => toast.remove(), 300);
    }, 3200);
  }

  // Cart Drawer UI
  function initCartDrawer() {
    let drawerOverlay = document.getElementById('cart-drawer-overlay');
    if (!drawerOverlay) {
      drawerOverlay = document.createElement('div');
      drawerOverlay.id = 'cart-drawer-overlay';
      drawerOverlay.className = 'cart-drawer-overlay';
      drawerOverlay.innerHTML = `
        <div class="cart-drawer" role="dialog" aria-modal="true" aria-label="Shopping Cart">
          <div class="cart-drawer-header">
            <h3><span class="veg-box"><span class="veg-circle"></span></span> Your Pure Veg Cart</h3>
            <button class="btn-close-drawer" id="btn-close-cart" aria-label="Close cart">&times;</button>
          </div>
          <div class="cart-items-list" id="cart-drawer-items">
            <!-- Dynamic Cart Items -->
          </div>
          <div class="cart-drawer-footer">
            <div class="cart-summary-row">
              <span>Items Total:</span>
              <span id="cart-drawer-subtotal">₹0</span>
            </div>
            <div class="cart-summary-row">
              <span>Packaging & Taxes:</span>
              <span>Calculated at checkout</span>
            </div>
            <div class="cart-summary-row cart-summary-total">
              <span>Estimated Subtotal:</span>
              <span id="cart-drawer-total">₹0</span>
            </div>
            <div style="margin-top: 18px; display: flex; gap: 10px;">
              <a href="cart.html" class="btn btn-primary" style="flex: 1; text-align: center;">Proceed to Checkout</a>
            </div>
          </div>
        </div>
      `;
      document.body.appendChild(drawerOverlay);

      document.getElementById('btn-close-cart').addEventListener('click', toggleCartDrawer);
      drawerOverlay.addEventListener('click', (e) => {
        if (e.target === drawerOverlay) toggleCartDrawer();
      });
    }

    renderCartDrawerItems();
    cart.addListener(renderCartDrawerItems);
  }

  function toggleCartDrawer() {
    const overlay = document.getElementById('cart-drawer-overlay');
    if (overlay) {
      overlay.classList.toggle('active');
    }
  }

  function renderCartDrawerItems() {
    const container = document.getElementById('cart-drawer-items');
    const subtotalEl = document.getElementById('cart-drawer-subtotal');
    const totalEl = document.getElementById('cart-drawer-total');
    if (!container) return;

    if (cart.items.length === 0) {
      container.innerHTML = `
        <div style="text-align: center; padding: 40px 10px; color: var(--stone-500);">
          <div style="font-size: 2.8rem; margin-bottom: 12px;">🥗</div>
          <h4 style="font-size: 1.15rem; color: var(--stone-800); margin-bottom: 6px;">Your cart is empty</h4>
          <p style="font-size: 0.9rem;">Explore our 100% pure vegetarian Himalayan specialties and add your favorites!</p>
          <a href="menu.html" class="btn btn-outline btn-sm" style="margin-top: 18px;">Browse Menu</a>
        </div>
      `;
      if (subtotalEl) subtotalEl.textContent = '₹0';
      if (totalEl) totalEl.textContent = '₹0';
      return;
    }

    container.innerHTML = cart.items.map(item => `
      <div class="cart-item">
        <div class="cart-item-info">
          <div style="display: flex; align-items: center; gap: 6px;">
            <span class="veg-box"><span class="veg-circle"></span></span>
            <div class="cart-item-title">${item.name}</div>
          </div>
          <div class="cart-item-price">₹${item.price} &times; ${item.quantity} = ₹${item.price * item.quantity}</div>
        </div>
        <div class="quantity-control">
          <button class="qty-btn" onclick="ROCK_STONE.cart.updateQuantity('${item.id}', ${item.quantity - 1})">-</button>
          <span class="qty-display">${item.quantity}</span>
          <button class="qty-btn" onclick="ROCK_STONE.cart.updateQuantity('${item.id}', ${item.quantity + 1})">+</button>
        </div>
      </div>
    `).join('');

    const subtotal = cart.getSubtotal();
    if (subtotalEl) subtotalEl.textContent = `₹${subtotal}`;
    if (totalEl) totalEl.textContent = `₹${subtotal}`;
  }

  // Header scroll observer
  function initHeaderScroll() {
    const header = document.querySelector('.site-header');
    if (!header) return;
    window.addEventListener('scroll', () => {
      if (window.scrollY > 40) {
        header.classList.add('scrolled');
      } else {
        header.classList.remove('scrolled');
      }
    }, { passive: true });
  }

  // Initialize on DOM ready
  document.addEventListener('DOMContentLoaded', () => {
    initHeaderScroll();
    initCartDrawer();
    cart.updateHeaderBadge();

    // Bind all cart buttons in header
    document.querySelectorAll('.cart-btn-header').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        toggleCartDrawer();
      });
    });
  });

  return {
    INFO: RESTAURANT_INFO,
    MENU: SAMPLE_MENU,
    cart: cart,
    showToast: showToast,
    toggleCartDrawer: toggleCartDrawer
  };
})();
