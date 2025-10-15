import 'package:flutter/material.dart';
import 'package:jmas_desktop/contollers/productos_controller.dart';

class DetailsProductoAuxiliar extends StatefulWidget {
  final int idProducto;
  final String nombreProducto;
  final Map<int, ProductosOptimizado>? productosCache;
  final Widget child;

  const DetailsProductoAuxiliar({
    super.key,
    required this.idProducto,
    required this.nombreProducto,
    required this.productosCache,
    required this.child,
  });

  @override
  State<DetailsProductoAuxiliar> createState() =>
      _DetailsProductoAuxiliarState();
}

class _DetailsProductoAuxiliarState extends State<DetailsProductoAuxiliar> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showTooltip(BuildContext context) {
    if (_overlayEntry != null) return;

    final producto = widget.productosCache?[widget.idProducto];
    if (producto == null) {
      print('Producto no encontrado en cache para ID: ${widget.idProducto}');
      return;
    }

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 8,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 8),
          child: Material(
            color: Colors.transparent,
            child: _buildProductoDetails(producto),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildProductoDetails(ProductosOptimizado producto) {
    return MouseRegion(
      onExit: (_) => _removeOverlay(),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Icon(Icons.inventory_2,
                      size: 18, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Detalles del Producto',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Nombre del producto
            Text(
              widget.nombreProducto,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Detalles
            _buildDetailRow(
                'Costo:',
                '\$${producto.prodCosto?.toStringAsFixed(2) ?? 'N/A'}',
                Icons.attach_money),
            _buildDetailRow(
                'Existencia:',
                '${producto.prodExistencia?.toStringAsFixed(2) ?? 'N/A'}',
                Icons.inventory),
            _buildDetailRow('Unidad Salida:', producto.prodUMedSalida ?? 'N/A',
                Icons.arrow_outward),
            _buildDetailRow('Unidad Entrada:',
                producto.prodUMedEntrada ?? 'N/A', Icons.arrow_downward),
            _buildDetailRow('Ubicación:', producto.prodUbFisica ?? 'N/A',
                Icons.location_on),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => _showTooltip(context),
        onExit: (_) => _removeOverlay(),
        child: GestureDetector(
          onTap: () {
            if (_overlayEntry == null) {
              _showTooltip(context);
            } else {
              _removeOverlay();
            }
          },
          child: widget.child,
        ),
      ),
    );
  }
}
