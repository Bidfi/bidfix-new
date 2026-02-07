import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';

export interface Service {
  id: string;
  service_name: string;
  category: string;
  description: string;
  availability: string;
  pending_bids_count: number;
  created_at: string;
}

export const useServices = (userId: string | undefined) => {
  const [services, setServices] = useState<Service[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchServices = async () => {
    if (!userId) return;
    setLoading(true);
    setError(null);

    try {
      const { data, error: fetchError } = await supabase
        .from('vendor_services')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false });

      if (fetchError) throw fetchError;
      setServices(data || []);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchServices();
  }, [userId]);

  const addService = async (serviceName: string, category: string, description: string, availability: string) => {
    if (!userId) throw new Error('User not authenticated');

    try {
      const { data, error: insertError } = await supabase
        .from('vendor_services')
        .insert([
          {
            user_id: userId,
            service_name: serviceName,
            category,
            description,
            availability,
          },
        ])
        .select()
        .single();

      if (insertError) throw insertError;
      setServices([data, ...services]);
      return data;
    } catch (err: any) {
      setError(err.message);
      throw err;
    }
  };

  const deleteService = async (serviceId: string) => {
    try {
      const { error: deleteError } = await supabase
        .from('vendor_services')
        .delete()
        .eq('id', serviceId);

      if (deleteError) throw deleteError;
      setServices(services.filter(s => s.id !== serviceId));
    } catch (err: any) {
      setError(err.message);
      throw err;
    }
  };

  return { services, loading, error, addService, deleteService, refetch: fetchServices };
};
