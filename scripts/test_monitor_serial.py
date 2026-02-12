#!/usr/bin/env python3
"""
Unit tests for monitor_serial.py

Tests port availability checking and retry logic.
"""

import unittest
import os
import time
from unittest.mock import patch, MagicMock
import sys

# Import the module under test
sys.path.insert(0, os.path.dirname(__file__))
import monitor_serial


class TestPortAvailability(unittest.TestCase):
    """Test port availability checking"""
    
    def test_wait_for_port_exists_immediately(self):
        """Test wait_for_port when port exists immediately"""
        with patch('os.path.exists', return_value=True):
            result = monitor_serial.wait_for_port('/dev/ttyUSB0', timeout=5, check_interval=0.1)
            self.assertTrue(result)
    
    def test_wait_for_port_exists_after_delay(self):
        """Test wait_for_port when port appears after delay"""
        # Simulate port appearing after 2 checks
        call_count = [0]
        def exists_side_effect(path):
            call_count[0] += 1
            return call_count[0] > 2
        
        with patch('os.path.exists', side_effect=exists_side_effect):
            with patch('time.sleep'):  # Mock sleep to speed up test
                result = monitor_serial.wait_for_port('/dev/ttyUSB0', timeout=5, check_interval=0.1)
                self.assertTrue(result)
    
    def test_wait_for_port_timeout(self):
        """Test wait_for_port timeout when port never appears"""
        with patch('os.path.exists', return_value=False):
            with patch('time.sleep'):  # Mock sleep to speed up test
                result = monitor_serial.wait_for_port('/dev/ttyUSB0', timeout=0.5, check_interval=0.1)
                self.assertFalse(result)
    
    def test_is_port_ready_success(self):
        """Test is_port_ready when port can be opened"""
        mock_serial = MagicMock()
        with patch('serial.Serial', return_value=mock_serial):
            result = monitor_serial.is_port_ready('/dev/ttyUSB0', 115200)
            self.assertTrue(result)
            mock_serial.close.assert_called_once()
    
    def test_is_port_ready_not_configured(self):
        """Test is_port_ready when port returns 'Device not configured' error"""
        with patch('serial.Serial', side_effect=OSError(6, 'Device not configured')):
            result = monitor_serial.is_port_ready('/dev/ttyUSB0', 115200)
            self.assertFalse(result)
    
    def test_is_port_ready_other_error(self):
        """Test is_port_ready with other serial errors"""
        with patch('serial.Serial', side_effect=Exception('Other error')):
            result = monitor_serial.is_port_ready('/dev/ttyUSB0', 115200)
            self.assertFalse(result)


class TestMonitorWithRetry(unittest.TestCase):
    """Test monitor_serial with retry logic"""
    
    def test_monitor_serial_with_retry_success_first_try(self):
        """Test monitoring succeeds on first try"""
        mock_serial = MagicMock()
        mock_serial.in_waiting = 0
        
        # Create a time counter that increments
        time_counter = [0]
        def mock_time():
            time_counter[0] += 0.1
            return time_counter[0]
        
        with patch('os.path.exists', return_value=True):
            with patch('monitor_serial.is_port_ready', return_value=True):
                with patch('serial.Serial', return_value=mock_serial):
                    with patch('time.time', side_effect=mock_time):
                        with patch('time.sleep'):  # Mock sleep to speed up test
                            result = monitor_serial.monitor_serial_with_retry(
                                '/dev/ttyUSB0', 115200, duration=1, output_file=None,
                                port_timeout=5, port_check_interval=0.5
                            )
                            self.assertIsNotNone(result)
    
    def test_monitor_serial_with_retry_port_not_ready(self):
        """Test monitoring when port is not ready within timeout"""
        with patch('os.path.exists', return_value=False):
            with patch('time.sleep'):
                result = monitor_serial.monitor_serial_with_retry(
                    '/dev/ttyUSB0', 115200, duration=1, output_file=None,
                    port_timeout=0.5, port_check_interval=0.1
                )
                self.assertIsNone(result)


if __name__ == '__main__':
    unittest.main()
