import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useServices } from '../hooks/useServices';
import { LogOut, Plus, Trash2, AlertCircle, CheckCircle, Tag, FileText, Clock } from 'lucide-react';

export const Dashboard: React.FC = () => {
  const { user, signOut } = useAuth();
  const navigate = useNavigate();
  const { services, loading, error, addService, deleteService } = useServices(user?.id);

  const [formData, setFormData] = useState({
    serviceName: '',
    category: 'Photography & Media',
    description: '',
    availability: 'ASAP',
  });
  const [submitting, setSubmitting] = useState(false);
  const [successMessage, setSuccessMessage] = useState('');

  const categories = [
    'Travel & Transport',
    'Vehicle Parts & Accessories',
    'Office Requirements',
    'Customized Office Solutions',
    'Home Furniture',
    'Home Appliances',
    'Photography & Media',
    'Catering & Food Services',
    'Event Planning',
    'Electrical & Maintenance',
    'Cleaning & Landscaping',
    'Other',
  ];

  const handleSignOut = async () => {
    try {
      await signOut();
      navigate('/login');
    } catch (err) {
      console.error('Sign out error:', err);
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    setSuccessMessage('');

    try {
      await addService(
        formData.serviceName,
        formData.category,
        formData.description,
        formData.availability
      );
      setFormData({ serviceName: '', category: 'Photography & Media', description: '', availability: 'ASAP' });
      setSuccessMessage('Service posted successfully!');
      setTimeout(() => setSuccessMessage(''), 3000);
    } catch (err) {
      console.error('Error adding service:', err);
    } finally {
      setSubmitting(false);
    }
  };

  const handleDeleteService = async (serviceId: string) => {
    if (window.confirm('Are you sure you want to delete this service?')) {
      try {
        await deleteService(serviceId);
      } catch (err) {
        console.error('Error deleting service:', err);
      }
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-slate-100">
      <nav className="bg-white shadow-sm border-b border-slate-200 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
          <h1 className="text-2xl font-bold text-blue-600">BidFix Vendor</h1>
          <button
            onClick={handleSignOut}
            className="flex items-center gap-2 bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg transition duration-200"
          >
            <LogOut size={18} />
            Sign Out
          </button>
        </div>
      </nav>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <div className="lg:col-span-2 space-y-8">
            <div className="bg-white rounded-lg shadow-lg p-8">
              <div className="flex items-center gap-3 mb-6">
                <Plus className="text-blue-600" size={28} />
                <h2 className="text-2xl font-bold text-slate-900">Post New Service</h2>
              </div>

              {successMessage && (
                <div className="mb-6 p-4 bg-green-50 border border-green-200 rounded-lg flex gap-3">
                  <CheckCircle className="text-green-600 flex-shrink-0" size={20} />
                  <p className="text-sm text-green-700">{successMessage}</p>
                </div>
              )}

              <form onSubmit={handleSubmit} className="space-y-5">
                <div>
                  <label htmlFor="serviceName" className="block text-sm font-medium text-slate-700 mb-2">
                    Service Name
                  </label>
                  <input
                    id="serviceName"
                    name="serviceName"
                    type="text"
                    value={formData.serviceName}
                    onChange={handleInputChange}
                    required
                    className="w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition"
                    placeholder="e.g., Professional Portrait Photography"
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label htmlFor="category" className="block text-sm font-medium text-slate-700 mb-2">
                      Category
                    </label>
                    <div className="relative">
                      <Tag className="absolute left-3 top-2.5 text-slate-400" size={20} />
                      <select
                        id="category"
                        name="category"
                        value={formData.category}
                        onChange={handleInputChange}
                        className="w-full pl-10 pr-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition bg-white appearance-none"
                      >
                        {categories.map(cat => (
                          <option key={cat} value={cat}>{cat}</option>
                        ))}
                      </select>
                    </div>
                  </div>

                  <div>
                    <label htmlFor="availability" className="block text-sm font-medium text-slate-700 mb-2">
                      Availability
                    </label>
                    <div className="relative">
                      <Clock className="absolute left-3 top-2.5 text-slate-400" size={20} />
                      <select
                        id="availability"
                        name="availability"
                        value={formData.availability}
                        onChange={handleInputChange}
                        className="w-full pl-10 pr-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition bg-white appearance-none"
                      >
                        <option value="ASAP">ASAP</option>
                        <option value="This week">This week</option>
                        <option value="Next week">Next week</option>
                        <option value="2 weeks">2 weeks</option>
                        <option value="1 month">1 month</option>
                        <option value="Flexible">Flexible</option>
                      </select>
                    </div>
                  </div>
                </div>

                <div>
                  <label htmlFor="description" className="block text-sm font-medium text-slate-700 mb-2">
                    Description
                  </label>
                  <div className="relative">
                    <FileText className="absolute left-3 top-2.5 text-slate-400" size={20} />
                    <textarea
                      id="description"
                      name="description"
                      value={formData.description}
                      onChange={handleInputChange}
                      required
                      rows={4}
                      className="w-full pl-10 pr-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition resize-none"
                      placeholder="Describe your service in detail..."
                    />
                  </div>
                </div>

                <button
                  type="submit"
                  disabled={submitting}
                  className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-blue-400 text-white font-semibold py-2.5 px-4 rounded-lg transition duration-200 transform hover:scale-105 active:scale-95"
                >
                  {submitting ? 'Posting Service...' : 'Post Service'}
                </button>
              </form>
            </div>

            <div className="bg-white rounded-lg shadow-lg p-8">
              <h2 className="text-2xl font-bold text-slate-900 mb-6">My Active Services</h2>

              {loading ? (
                <div className="flex justify-center py-8">
                  <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-blue-600"></div>
                </div>
              ) : services.length === 0 ? (
                <div className="text-center py-8">
                  <p className="text-slate-600">No services posted yet. Create your first service above!</p>
                </div>
              ) : (
                <div className="space-y-4">
                  {services.map(service => (
                    <div key={service.id} className="border border-slate-200 rounded-lg p-5 hover:shadow-md transition">
                      <div className="flex justify-between items-start gap-4">
                        <div className="flex-1">
                          <h3 className="text-lg font-semibold text-slate-900">{service.service_name}</h3>
                          <p className="text-sm text-slate-600 mt-1">{service.category}</p>
                          <p className="text-slate-700 mt-2">{service.description}</p>
                          <div className="flex flex-wrap items-center gap-4 mt-3">
                            <div className="flex items-center gap-2">
                              <Clock size={18} className="text-slate-500" />
                              <span className="text-sm text-slate-700 font-medium">{service.availability}</span>
                            </div>
                            <div className="flex items-center gap-2 bg-blue-50 px-3 py-1 rounded-lg">
                              <span className="text-sm font-bold text-blue-600">{service.pending_bids_count}</span>
                              <span className="text-sm text-blue-700">{service.pending_bids_count === 1 ? 'Bid' : 'Bids'}</span>
                            </div>
                            <span className="text-xs text-slate-500 ml-auto">
                              {new Date(service.created_at).toLocaleDateString()}
                            </span>
                          </div>
                        </div>
                        <button
                          onClick={() => handleDeleteService(service.id)}
                          className="p-2 hover:bg-red-50 rounded-lg transition text-red-600 hover:text-red-700"
                        >
                          <Trash2 size={20} />
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>

          <div className="lg:col-span-1">
            <div className="bg-white rounded-lg shadow-lg p-6 sticky top-24">
              <h3 className="text-lg font-bold text-slate-900 mb-4">Live Bids</h3>
              <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 text-center">
                <AlertCircle className="mx-auto text-blue-600 mb-3" size={32} />
                <p className="text-slate-700 font-medium">No new bids yet</p>
                <p className="text-sm text-slate-600 mt-2">Bids from customers will appear here</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
